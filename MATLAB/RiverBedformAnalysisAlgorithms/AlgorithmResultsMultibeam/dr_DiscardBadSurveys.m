clear
clc
close all

load("MoRiverMultibeamData.mat");
filename = "SurveysToRemove.txt";
lines = readlines(filename);
isHeader = contains(lines, ':') | strlength(strtrim(lines)) == 0;
fileNames = lines(~isHeader);

indicesToRemove = [];

for i = 1:length(MoRiverData)
    % remove any depths greater than 50 m or less than 0 m
    if mean(MoRiverData(i).h) > 50 || mean(MoRiverData(i).h) < 0
        indicesToRemove = [indicesToRemove; i];
    end
    % remove based on filenames recorded from QAQC
    if ismember(MoRiverData(i).Filename, fileNames)
        indicesToRemove = [indicesToRemove; i];
    end

    % limit between RM 0 - RM 360
    if MoRiverData(i).ProfileRiverMile{1,1}(1) > 360
        indicesToRemove = [indicesToRemove; i];
    end

    % limit date after 2020
    if MoRiverData(i).Date < datetime("2021-01-01")
        indicesToRemove = [indicesToRemove; i];
    end
end

indicesToRemove = unique(indicesToRemove);

MoRiverData(indicesToRemove) = [];

save("MoRiverMultibeamData.mat", "MoRiverData");
