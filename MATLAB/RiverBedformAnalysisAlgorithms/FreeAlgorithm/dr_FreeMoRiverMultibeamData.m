clear
clc
close all

addpath('.\MoRiverBedformIdentification\');
addpath('.\MoRiverBedformIdentification\VectorMath\');
addpath('..\..\..\Multibeam Data\MoRiver\OutputMATLABFiles\');
addpath('..\..\MAW MATLAB\');

%% Parameters
    filenamePath = "..\..\..\Multibeam Data\MoRiver\ExcelSpreadsheets\";
    savePath = "..\AlgorithmResultsMultibeam\MoRiver\";
    fileNames = getFilenames(filenamePath);

%% Loop
    for i = 1:length(fileNames)
        f = fileNames(i);
        f = f.split(".");
        filename = f(1);

        %% Get Data
            Data = getProfileData(filename, 75, 0.0675*3.28084);

        %% Plot Average Length Along Transverse
            %plotLengthsVsTransverse(Data.avgLengths);

        %% Save Results
            saveMultibeamResultsToFile(filename, Data, 1, savePath);
            fprintf("Finished: %d/%d\n", i,length(fileNames))
            close all;
    end