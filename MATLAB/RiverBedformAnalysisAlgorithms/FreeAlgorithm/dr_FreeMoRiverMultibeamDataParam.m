clear
clc
close all

addpath('.\MoRiverBedformIdentification\');
addpath('.\MoRiverBedformIdentification\VectorMath\');
addpath('..\..\..\Multibeam Data\MoRiver\OutputMATLABFiles\');
addpath('..\..\MAW MATLAB\');

%% Parameters
    filenamePath = "..\..\..\Multibeam Data\MoRiver\ExcelSpreadsheets\";
    fileNames = getFilenames(filenamePath);
    prominenceValues = linspace(0.1, 0.5, 25);
    
%% Loop
    for i = 1:length(prominenceValues)
        f = fileNames(6);
        f = f.split(".");
        filename = f(1);

        %% Get Data
            Data1(i) = getProfileData(filename, 50, prominenceValues(i));
            Data2(i) = getProfileData(filename, 100, prominenceValues(i));
            fprintf("Finished: %d/%d\n", i,length(prominenceValues))
    end

%% Plot
    figure;
        plot(prominenceValues, arrayfun(@(x) mean(x.c2), Data1), prominenceValues, arrayfun(@(x) mean(x.c2), Data2))
    figure
        plot(prominenceValues, arrayfun(@(x) length(x.c2), Data1));

    % for i = 1:length(prominenceValues)
    %     figure;
    %     plot(Data1(i).propsPrim(1).smoothS, Data1(i).propsPrim(1).smoothZ)
    %     hold on;
    %     plot(Data1(i).propsPrim(1).smoothS(Data1(i).propsPrim(1).peakIndices), Data1(i).propsPrim(1).smoothZ(Data1(i).propsPrim(1).peakIndices), 'ro')
    %     plot(Data1(i).propsPrim(1).smoothS(Data1(i).propsPrim(1).troughIndices), Data1(i).propsPrim(1).smoothZ(Data1(i).propsPrim(1).troughIndices), 'bo')
    %     axis equal
    %     title(sprintf("%f", prominenceValues(i)))
    %     daspect([0.025, 1, 1])
    % end