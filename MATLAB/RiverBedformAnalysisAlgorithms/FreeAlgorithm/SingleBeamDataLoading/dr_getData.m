clear
clc
close all

%% Load Data Object

% gets the data into a table from excel
% only need to call the constructor when using new data from excel
% this step may take a while to read from excel
% .mat file used below contains the necessary rawData class structure
    rawData = cMODataLoad();

% loads rawData.mat to retrieve object variable
    % rawData = load("rawData.mat");
    % rawData = rawData.rawData;

%% Convert To Struct
% converts the table into a formated struct
    for n = 1:4
        MoData(n).Center = makeStruct(rawData, "Center", n);
        MoData(n).Left = makeStruct(rawData, "Left", n);
        MoData(n).Right = makeStruct(rawData, "Right", n);
    end

% extra information added to new fields
% size of vector, river mile length of scan
    for n = 1:4
        MoData(n).Center.size = size(MoData(n).Center.x);
        MoData(n).Center.riverMileLength = MoData(n).Center.x(MoData(n).Center.size, 1) - MoData(n).Center.x(1, 1);
    
        MoData(n).Right.size = size(MoData(n).Right.x);
        MoData(n).Right.riverMileLength = MoData(n).Right.x(MoData(n).Right.size, 1) - MoData(n).Right.x(1, 1); 
    
        MoData(n).Left.size = size(MoData(n).Left.x);
        MoData(n).Left.riverMileLength = MoData(n).Left.x(MoData(n).Left.size, 1) - MoData(n).Left.x(1, 1); 
    end

%% Save To File
% saves the data in .mat format to be used
% checks to see if filename is valid or creates a new name
    path = "..\";
    filename = "MoRiverData.mat";
    i = 1;

    while isfile(sprintf('%s%s', path, filename))
        filename = sprintf("%s%s%d%s", path, "MoRiverData", i, ".mat");
    end
    
    save(filename, "MoData");
