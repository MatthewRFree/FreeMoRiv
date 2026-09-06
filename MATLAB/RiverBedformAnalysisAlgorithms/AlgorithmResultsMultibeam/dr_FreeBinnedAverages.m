clear
clc
close all

addpath(".\Plotting Functions\")
addpath("..\..\..\Multibeam Data\SupplementalRiverData\")

%% Load Data
    [AllRMS, AllLs, AllHs, Allhs, AllDates, AllFilenames, AllQ, AllStats] = binData(0.1);

    T = table('Size', [4313 17], ...
          'VariableTypes', {'string', 'datetime', 'double', 'double', 'double', 'double', 'double', 'double', 'double', 'double',...
          'double', 'double','double', 'double','double', 'double','double'}, ...
          'VariableNames', {'FileName', 'Date', 'RiverMile', 'Q', 'AverageFlowDepth', 'AverageHeight', 'AverageLength',...
          'LengthPercentile95', 'LengthPercentile75', 'LengthMedian', 'LengthPercentile25', 'LengthPercentile5',...
          'HeightPercentile95', 'HeightPercentile75', 'HeightMedian', 'HeightPercentile25', 'HeightPercentile5'}); 
    
    %% Table For Excel
            T.Q                     = AllQ;
            T.FileName              = AllFilenames;
            T.AverageLength         = AllLs;
            T.AverageHeight         = AllHs;
            T.RiverMile             = AllRMS;
            T.AverageFlowDepth      = Allhs;
            T.Date                  = AllDates;
            T.LengthPercentile95    = AllStats.L95;
            T.LengthPercentile75    = AllStats.L75;
            T.LengthMedian          = AllStats.L50;
            T.LengthPercentile25    = AllStats.L25;
            T.LengthPercentile5     = AllStats.L5;
            T.HeightPercentile95    = AllStats.H95;
            T.HeightPercentile75    = AllStats.H75;
            T.HeightMedian          = AllStats.H50;
            T.HeightPercentile25    = AllStats.H25;
            T.HeightPercentile5     = AllStats.H5;

        writetable(T, "BinnedDataTable.xlsx");