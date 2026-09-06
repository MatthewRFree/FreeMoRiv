clear
clc
close all

addpath("..\..\..\..\Single Beam Data\Supplementary Data\USGS Gage Data\")

gageLocs = [
    "Atchison (KS), USGS 06818300"
    "Boonville (MO), USGS 06909000"
    "Glasgow (MO), USGS 06906500"
    "Hermann (MO), USGS 06934500"
    "Jefferson City (MO), USGS 06910450"
    "Kansas City (MO), USGS 06893000"
    "Leavenworth (KS), USGS 06820475"
    "Napoleon (MO), USGS 06894650"
    "Rulo (NE), USGS 06813500"
    "St. Charles (MO), USGS 06935965"
    "St. Joseph (MO), USGS 06818000"
    "Washington (MO), USGS 06935450"
    "Waverly (MO), USGS 06895500"
];

for i = 1:length(gageLocs)
    TH = readtable(sprintf("%s H.txt",gageLocs(i)));
    if i ~= 1 && i ~= 7
        TQ = readtable(sprintf("%s Q.txt",gageLocs(i)));
    else
        % Atchison and Leavenworth missing Q (cfs) data
        % Take data from Rulo (NE) since it is closest upstream
        TQ = readtable(sprintf("%s Q.txt",gageLocs(9)));
    end

    Dates_TH = TH{:,3};
    H = TH{:,5};
    Dates_TQ = TQ{:,3};
    Q = TQ{:,5};
    
    TH = timetable(Dates_TH, H);
    TQ = timetable(Dates_TQ, Q);
    
    THAverage = retime(TH, 'daily', 'mean');
    TQAverage = retime(TQ, 'daily', 'mean');
    
    GageData = synchronize(THAverage, TQAverage, 'union');
    GageData.Properties.VariableNames = {'H', 'Q'};
    GageData = fillmissing(GageData, 'linear');

    save(sprintf("%s.mat",gageLocs(i)), "GageData");
end