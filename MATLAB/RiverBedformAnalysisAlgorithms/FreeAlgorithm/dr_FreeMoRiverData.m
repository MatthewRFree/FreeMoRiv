clear
clc
close all

addpath('.\MoRiverBedformIdentification\');
addpath('.\MoRiverBedformIdentification\VectorMath\');
addpath("..\..\..\Single Beam Data\")

%% Variables
    xStart = 132; % starting mile
    xLength = 2; % plot length (miles)
    month1 = "June";
    Axis = "Center";

%% Parameters
    primaryProminence = 0.75;
    secondaryProminence = 0.01;

%% Get Data
    load("MoRiverData.mat");

    % get the x, y data
        [x1, y1, x2, y2] = getRiverData(MoData, xStart, xLength, month1, Axis);
    
    % data must be smoothed (sparingly) to distinguish peaks
        [smoothX, smoothY] = curveSmoothing(x1, y1, 1, 25);

    % Primary
        propsPrim = duneHeightLength(smoothX, smoothY, primaryProminence);

    % Secondary
        propsSec = duneHeightLength(smoothX, smoothY, secondaryProminence);

    % Get data from structs for histogram
        primaryLength = propsPrim.totalLength; secondaryLength = propsSec.totalLength; primaryHeight = propsPrim.avgHeight; secondaryHeight = propsSec.avgHeight;
        pPeaks = propsPrim.peakIndices; pTroughs = propsPrim.troughIndices; sPeaks = propsSec.peakIndices; sTroughs = propsSec.troughIndices;

%% Plot Data
    plotDuneHeightLength(month1, smoothX, smoothY, pPeaks, pTroughs, primaryHeight, secondaryHeight, primaryLength, secondaryLength);

%% Write Data
    parameters = struct('primaryProminence', primaryProminence, 'secondaryProminence', secondaryProminence);
    saveResultsToFile(xStart, xLength, month1, parameters, smoothX, smoothY, pPeaks, pTroughs, sPeaks, sTroughs, primaryHeight, secondaryHeight, primaryLength, secondaryLength, 'Free', Axis);