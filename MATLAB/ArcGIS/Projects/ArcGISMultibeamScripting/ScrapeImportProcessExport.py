# SCRAPE IMPORT PROCESS EXPORT Script
#
# This script allows for the automation of retrieval of data from the eHydro
# database platform maintained by the Army Corps of Engineers. It then processes
# raw bathymetric data into individual profile lines that are more easily analyzed.
# Once run, this script produces CSV files that can be run through dune finding
# algorithms to retrieve the bedform scales
#
# INPUTS
#
# There are various variables that can be changed, however they have all been fine-tuned
# and hardcoded. The ones necessary to change have comments listed above them below. They
# include paths for import and export file locations, as well as the gdb location for where
# this script is downloaded on any given computer.
#
# Also available for change are the input parameters for scraping. The script will gather all
# files found within a region bounding box defined by (long,lat,long,lat) WGS84 coordinates.
# It will also find all files beginning at a given date up to the present.
#
# NOTE
#
# A copy of this script is kept within the root of the ArcGIS project folder. This script uses
# arcpy functions and therefore must be run within the embedded script in the project file,
# where the embedded script is found inside the project toolboxes. The added file in the project
# root was added as embedded scripts have a bug where they sometimes are overwritten, and
# all work is lost (ArcGIS keeps active scripts in a temp file and deletes when closed). If this happens
# the saved script in the .py file can simply be copy pasted into ArcGIS and run once again!
#
# Author: Matthew Free
# 9/17/2025
#
# Imports
#
import os
import io
import re
import numpy as np
import csv
import arcpy
import shutil
import requests
import zipfile
import datetime
import traceback
#
# Functions
#
def interpolateShapeLocal(raster, sailingLine, centerXY, searchRadius, interpPolyLine):
    x, y = centerXY
    spatialReference5070 = arcpy.SpatialReference(5070)
    boundingBox = arcpy.Polygon(arcpy.Array([
        arcpy.Point(x - searchRadius, y - searchRadius),
        arcpy.Point(x - searchRadius, y + searchRadius),
        arcpy.Point(x + searchRadius, y + searchRadius),
        arcpy.Point(x + searchRadius, y - searchRadius),
        arcpy.Point(x - searchRadius, y - searchRadius),]), spatialReference5070)
    trimmedSailingLine = "TrimmedSailingLine"
    arcpy.analysis.Clip(sailingLine, boundingBox, trimmedSailingLine)
    arcpy.CheckOutExtension("3D")
    arcpy.ddd.InterpolateShape(raster, trimmedSailingLine, interpPolyLine)
    arcpy.CheckInExtension("3D")
    return interpPolyLine
#
def getXYPoint(xyPoints):
    with arcpy.da.SearchCursor(xyPoints, ["SHAPE@XY"]) as cursor:
        for row in cursor:
            return row[0]
#
def queryBoundingBox(startDate, boundingBox, numberOfSlices=3):
    # ArcGIS Feature Service endpoint
    url = "https://services7.arcgis.com/n1YM8pTrFmm7L4hs/arcgis/rest/services/eHydro_Survey_Data/FeatureServer/0/query"
    xmin, ymin, xmax, ymax = boundingBox
    latitudeStep = (ymax - ymin) / numberOfSlices
    allFeatures = []
    for i in range(numberOfSlices):
        sliceymin = ymin + i * latitudeStep
        sliceymax = ymin + (i + 1) * latitudeStep
        #
        # Response
        params = {
            "f": "json",
            "where": f"dateuploaded >= timestamp '{startDate}'",
            "outFields": "sourcedatalocation",
            "returnGeometry": False,
            "geometry": f"{xmin}, {sliceymin}, {xmax}, {sliceymax}",
            "geomtryType": "esriGeometryEnvelope",
            "inSR": 4326,
            "spatialRel": "esriSpatialRelIntersects",
            "resultRecordCount": 2000  # Max records per request
        }
        response = requests.get(url, params=params)
        data = response.json()
        features = data.get("features", [])
        #
        # Recursively Call Function if limit is hit
        if len(features) == 2000:
            features = queryBoundingBox(startDate, (xmin, sliceymin, xmax, sliceymax))
        
        allFeatures += features
    return allFeatures
#
def isDataLine(line):
    parts = line.strip().split()
    if len(parts) >= 3:
        try:
            [float(part) for part in parts[:3]]
            return True
        except ValueError:
            return False
    return False
#
def extractWaterSurfaceElevation(lines):
    pattern = r'Water Surface Elevation:.*?([+-]?\d+(?:\.\d+)?)\s*ft'
    for line in lines:
        match = re.search(pattern, line)
        if match:
            return float(match.group(1))
    return None
#
def isCrossSection(x, y, gridSize=100, minimumDensity=100, densityCoverage=0.20):
    xBin = np.arange(np.min(x), np.max(x) + gridSize, gridSize)
    yBin = np.arange(np.min(y), np.max(y) + gridSize, gridSize)
    #
    # Bin data
    densityGridded, _, _ = np.histogram2d(x, y, bins=[xBin, yBin])
    #
    # Count cells above a threshold
    denseCells = np.sum(densityGridded >= minimumDensity)
    totalCells = np.prod(densityGridded.shape)
    #
    # Calculate the percentage of these cells to the total
    densityPercentage = denseCells / totalCells
    print(f"[Feet] Dense cells: {denseCells}, Total: {totalCells}, Fraction: {densityPercentage:.3f}")
    return densityPercentage < densityCoverage
#
def fixFilename(filename):
    riverMiles = re.search(r'(_(?:\d+_?)+)_SORT', filename)
    if not riverMiles:
        return None
    #
    # Pull RMs from the string
    numberString = riverMiles.group(1)
    numbers = [int(n) for n in numberString.strip('_').split('_')]
    #
    # Check if both trailing 0s missing
    if len(numbers) == 2:
        number1, number3 = numbers
        numbersFixed = [number1, 0, number3, 0]
    #
    # Check if only one trailing 0 missing
    elif len(numbers) == 3:
        big = [n for n in numbers if n >= 10]
        small = [n for n in numbers if n < 10]
        number1, number2, number3 = numbers
        if len(big) == 2 and len(small) == 1:
            #
            # Second trailing 0
            if number1 > number2 and number3 > number2:
                numbersFixed = [big[0], small, big[1], 0]
            #
            # First trailing 0
            elif number1 > number3 and number2 > number3:
                numbersFixed = [big[0], 0, big[1], small]
            else:
                return None
        else:
            return None
    else:
        return None
    #
    # Add new RMs to the string
    numberStringFixed = '_' + '_'.join(str(n) for n in numbersFixed)
    filenameFixed = filename.replace(numberString, numberStringFixed)
    return filenameFixed if filenameFixed != filename else None
#
def getCRSFromZIP(z, extractionDirectory):
    gdbFolder = None
    for name in z.namelist():
        parts = name.split('/')
        for part in parts:
            if part.lower().endswith('.gdb'):
                gdbFolder = part
                break
        if gdbFolder:
            break
    #
    if not gdbFolder:
        print("No .gdb folder found in the zip.")
        return None
    #
    exportDirectory = os.path.join(extractionDirectory, gdbFolder)
    #
    # Remove existing folder if exists
    if os.path.exists(exportDirectory):
        shutil.rmtree(exportDirectory)
    os.makedirs(exportDirectory, exist_ok=True)
    #
    # Extract all files inside the .gdb folder
    for member in z.namelist():
        if member.startswith(gdbFolder + '/'):
            filepath = os.path.relpath(member, gdbFolder)
            if filepath in ('.', '..'):
                continue
            exportPath = os.path.join(exportDirectory, filepath)
            os.makedirs(os.path.dirname(exportPath), exist_ok=True)
            if not member.endswith('/'):
                with z.open(member) as source, open(exportPath, 'wb') as destination:
                    shutil.copyfileobj(source, destination)
    #
    # Now read CRS info from extracted folder
    arcpy.env.workspace = exportDirectory
    featureClass = arcpy.ListFeatureClasses()
    if not featureClass:
        print("No feature classes found in the extracted .gdb.")
        return None
    #
    featureClassInfo = arcpy.Describe(featureClass[0])
    sr = featureClassInfo.spatialReference
    #
    # Clear workspace to release locks
    arcpy.ClearEnvironment("workspace")
    #
    return sr.exportToString()
#
def processAndExportCSV(inputPath, outputPath, sailingLine, spatialReference, rasterCellSize=1.6):
    basename = os.path.splitext(os.path.basename(inputPath))[0] + ".csv"
    #
    # Set up workspace
    # The path in the variable below needs to be changed to this projects Geodatabase
    # relative to whichever computer it is downloaded onto. Attempts were made to automate
    # this process however ArcGIS was not allowing for retrieval of the gdb location
    arcpy.env.workspace = r"C:\Users\g5edhmrf\OneDrive - US Army Corps of Engineers\Documents\ArcGIS\Projects\ArcGISMultibeamScripting\ArcGISMultibeamScripting.gdb"
    arcpy.env.overwriteOutput = True
    inputSpatialReference = arcpy.SpatialReference()
    inputSpatialReference.loadFromString(spatialReference)
    targetSpatialReference = arcpy.SpatialReference(5070) # NAD83 Albers Equal Area
    #
    # Set up workspace features
    inputPoints = "InputPoints"
    projectedPoints = "ProjectedPoints"
    raster = "Raster"
    interpPolyLine = "InterpolatedPolyline"
    outputPoints = "OutputPoints"
    xField = "X"
    yField = "Y"
    zField = "Z"
    #
    # Process File
    print("IMPORTING!\n")
    arcpy.management.XYTableToPoint(inputPath, inputPoints, xField, yField, zField, coordinate_system=inputSpatialReference)
    arcpy.management.Project(inputPoints, projectedPoints, targetSpatialReference)
    print("RASTERIZING!\n")
    arcpy.conversion.PointToRaster(projectedPoints, zField, raster, cellsize=rasterCellSize)
    centerXY = getXYPoint(projectedPoints)
    interpolateShapeLocal(raster, sailingLine, centerXY, 5000, interpPolyLine)
    print("EXPORTING!\n")
    arcpy.management.FeatureVerticesToPoints(interpPolyLine, outputPoints)
    arcpy.management.AddXY(outputPoints)
    arcpy.conversion.TableToTable(outputPoints, outputPath, basename)
    print("DONE!\n")
#
def downloadAndExtractXYZAsCSV(url, destinationDirectoryData, destinationDirectoryMetadata, minimumByteSize = 1000 * 1024):
    try:
        # Download ZIP file to memory
        response = requests.get(url)
        response.raise_for_status()
        with zipfile.ZipFile(io.BytesIO(response.content)) as z:
            # Find the .xyz file
            xyzFiles = [f for f in z.namelist() if f.lower().endswith('a.xyz')]
            if not xyzFiles:
                print(f"No .xyz Files Found in ZIP: {url}\n")
                return None, None
            xyzFile = xyzFiles[0]
            #
            # Check if File Size is too small (only save full surveys)
            fileInformation = z.getinfo(xyzFile)
            if fileInformation.file_size < minimumByteSize:
                print(f"Skipped (too small): {xyzFile}\n")
                return None, None
            #
            # Check and Redo Format
            with z.open(xyzFile) as f:
                lines = f.read().decode('utf-8').splitlines()
            #
            # Try to get water surface elevation
            waterSurfaceElevation = extractWaterSurfaceElevation(lines)
            #
            # Find where XYZ data starts
            dataStartIndex = next((i for i, line in enumerate(lines) if isDataLine(line)), None)
            if dataStartIndex is None:
                print(f"Skipped (no float data): {xyzFile}\n")
                return None, None
            #
            metaDataLines = lines[0:dataStartIndex]
            dataLines = lines[dataStartIndex:]
            dataOutput = ["X Y Z"]
            xCoords, yCoords = [], []
            #
            for line in dataLines:
                parts = line.strip().split()
                if len(parts) >= 3:
                    try:
                        x, y, depth = float(parts[0]), float(parts[1]), float(parts[2])
                        xCoords.append(x)
                        yCoords.append(y)
                        zModified = waterSurfaceElevation - depth if waterSurfaceElevation is not None else depth
                        dataOutput.append(f"{x:.3f} {y:.3f} {zModified:.3f}")
                    except ValueError:
                        continue
            #
            # Check for cross section
            if isCrossSection(xCoords, yCoords):
                print(f"Skipped (cross section): {xyzFile}\n")
                return None, None
            #
            # Get Coordinate System
            crsInfo = getCRSFromZIP(z, r"C:\Users\g5edhmrf\gdbCRS")
            #
            # Rename the Extension
            originalFileName = os.path.basename(xyzFile)
            newFileName = os.path.splitext(originalFileName)[0] + ".csv"
            fixedFileName = fixFilename(newFileName)
            if fixedFileName != None:
                print(fixedFileName)
                newFileName = fixedFileName
            savePathData = os.path.join(destinationDirectoryData, newFileName)
            savePathMetaData = os.path.join(destinationDirectoryMetadata, newFileName)
            #
            # Extract and save the renamed file
            with open(savePathData, "wb") as dataFileOut:
                dataFileOut.write("\n".join(dataOutput).encode('utf-8'))
            #
            with open(savePathMetaData, "wb") as metaFileOut:
                metaFileOut.write("\n".join(metaDataLines).encode('utf-8'))
            #
            print(f"Saved: {savePathData}" + "\n")
            return savePathData, crsInfo
    except Exception as e:
        print(f"Error processing {url}: {e}" + "\n")
        return None, None
#
# Parameters
startDate = "2001-01-01 00:00:00" ## Start date variable which can be edited for the query
boundingBox = (-100.6280018, 30.2334643, -90.4352473, 45.2359637) ## Geographic bounding box which can be edited for the query
lastRunURL = None
urls = queryBoundingBox(startDate, boundingBox)
urls = sorted(set([feature["attributes"]["sourcedatalocation"] for feature in urls]))
#
# Variables
inputPathData = r"" ## This needs to be changed to the location where raw eHydro Data will be improted to.
inputPathMetadata = r"" ## This needs to be changed to the location where raw eHydro metaData will be imported to.
outputPath = r"" ## This needs to be changed to where the processed files will be exported to.
# This set of profile lines has been included within this projects gdb folder.
# The path prior to the file itself needs to be changed to this projects Geodatabase
# relative to whichever computer it is downloaded onto. Attempts were made to automate
# this process however ArcGIS was not allowing for retrieval of the gdb location
sailingLine = r"C:\Users\g5edhmrf\OneDrive - US Army Corps of Engineers\Documents\ArcGIS\Projects\ArcGISMultibeamScripting\ArcGISMultibeamScripting.gdb\MissouriRiverProfileLines_5070"
processing = True if not lastRunURL else False
count = 1
# Loop
print(f"Found {len(urls)} surveys.\n")
for link in urls:
    print(f"Count {count}")
    count += 1
    try:
        if not processing:
            if lastRunURL == link:
                processing = True
                continue
        else:
            (savePath, crsString) = downloadAndExtractXYZAsCSV(link, inputPathData, inputPathMetadata)
            if savePath:
                processAndExportCSV(savePath, outputPath, sailingLine, crsString)
    except Exception as e:
        print(f"Error processing {link}: {e}" + "\n")
        traceback.print_exc()
#
#
