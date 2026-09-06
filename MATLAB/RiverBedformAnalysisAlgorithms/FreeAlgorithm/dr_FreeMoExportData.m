clear
clc
close all

path = "..\AlgorithmResultsMultibeam\MoRiver\";
addpath(".\MoRiverBedformIdentification\")
addpath("..\..\..\Multibeam Data\")
addpath("..\..\..\Multibeam Data\SupplementalRiverData\")
addpath(path)

%% Parameters
    sailingLineOffsets = [0, 10, -10, 20, -20, 30, -30, 40, -40, 50, -50, 60, -60, 70, -70, 80, -80, 90, -90, 100, -100];
    load("RiverMileCoordinates.mat")

%% Get FileNames
    fileNames = getFilenames(path);
    newFileNames = {};
    index = 1;
    for i = 1:length(fileNames)
        fileParts = split(fileNames{i}, "_")';
        fileParts = fileParts(1:end-1);
        newName = strjoin(fileParts, "_");

        if endsWith(newName, 'A')
            newFileNames{index,1} = string(newName);
            index = index + 1;
        end
    end
    fileNames = cell2mat(newFileNames);

%% Loop
    for i = 1:length(fileNames)
        filename = fileNames(i);

    % Get Date
        pieces = filename.split("_");
        if length(pieces) > 1
            date = pieces(4);
            date = datetime(strcat(extractBetween(date,1,4), "-", extractBetween(date,5,6), "-", extractBetween(date,7,8)));
        else
            date = nan;
        end

    % Get Gage Location
        if exist(sprintf("%s%s%s", "..\..\..\Multibeam Data\MoRiver\GaugeLocations\", filename, ".txt"))
            gageLoc = splitlines(string(fileread(sprintf("%s%s%s", "..\..\..\Multibeam Data\MoRiver\GaugeLocations\", filename, ".txt"))));
            gageLoc = getGageLoc(lower(strtrim(gageLoc(1))));
        else
            gageLoc = nan;
        end
    
    % Load Data
        dataFilename = sprintf("%s%s", filename, "_data.mat");
        load(dataFilename);

    % Get River Mile
        riverMiles = extractRiverMilesFromFilename(filename);
        riverMileStart = min(riverMiles);
        riverMileEnd = max(riverMiles);
 
    % Survey Info
        MoRiverData(i).L = Data.c2;
        MoRiverData(i).H = Data.c1;
        MoRiverData(i).h = Data.dunePeakDepths.*0.3048 + Data.c1./2;
        MoRiverData(i).Filename = filename;
        MoRiverData(i).Date = date;
        MoRiverData(i).RiverKmStart = 1.60934*riverMileStart;
        MoRiverData(i).RiverKmEnd = 1.60934*riverMileEnd;
        MoRiverData(i).RiverMileStart = riverMileStart;
        MoRiverData(i).RiverMileEnd = riverMileEnd;
        
    % Gage Info
        if ~ismissing(gageLoc)
            load(sprintf("%s%s%s","..\..\..\Multibeam Data\SupplementalRiverData\",gageLoc,".mat"))
            MoRiverData(i).GageHeight = 0.3048 * GageData{date, "H"};
            MoRiverData(i).Q = 0.0283168 * GageData{date, "Q"};
            MoRiverData(i).GageLocation = gageLoc;
        else
            MoRiverData(i).GageHeight = nan;
            MoRiverData(i).Q = nan;
            MoRiverData(i).GageLocation = gageLoc;
        end

    % Profile Info
        lengths = cellfun(@length, Data.primaryLength);
        endIndices = cumsum(lengths);
        startIndices = [1, endIndices(1:end-1) + 1];

        for j = 1:length(Data.primaryLength)
            MoRiverData(i).ProfileL{j,1} = Data.primaryLength{j}';
            MoRiverData(i).ProfileH{j,1} = Data.primaryHeight{j}';
            
            indexRangeDune = startIndices(j):endIndices(j);

            MoRiverData(i).Profileh{j,1} = MoRiverData(i).h(indexRangeDune);
            if ~ismissing(gageLoc)
                rm = getRiverMileFromCoordInterpolated(Data.duneEastings.peaks{j,:}, Data.duneNorthings.peaks{j,:}, 0.0001);
            else
                rm = nan;
            end
            MoRiverData(i).ProfileRiverMile{j,1} = rm;
            MoRiverData(i).ProfileRiverKm{j,1} = rm.*1.60934;
            MoRiverData(i).ProfileEastingPeak{j,1} = Data.duneEastings.peaks{j,:};
            MoRiverData(i).ProfileNorthingPeak{j,1} = Data.duneNorthings.peaks{j,:};
            MoRiverData(i).ProfileEastingTrough{j,1} = Data.duneEastings.troughs{j,:};
            MoRiverData(i).ProfileNorthingTrough{j,1} = Data.duneNorthings.troughs{j,:};
            MoRiverData(i).ProfileOffsetFromSailingLine(j,1) = sailingLineOffsets(j);
            MoRiverData(i).ProfileDuneInfo.S{j,1} = Data.propsPrim(j).smoothS';
            MoRiverData(i).ProfileDuneInfo.Z{j,1} = Data.propsPrim(j).smoothZ';
            MoRiverData(i).ProfileDuneInfo.PeakIndices{j,1} = Data.propsPrim(j).peakIndices';
            MoRiverData(i).ProfileDuneInfo.TroughIndices{j,1} = Data.propsPrim(j).troughIndices';
        end
    end

%% Save Results
    save("MoRiverMultibeamData.mat", "MoRiverData");