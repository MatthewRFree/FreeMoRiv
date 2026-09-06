function [AllRMS, AllLs, AllHs, Allhs, AllDates, AllFilenames, AllQ, AllStats] = binData(binSize, dataStructure)
% BINDATA Bins L, H, h, and river mile values for each multibeam profile.
%   BINDATA loads MoRiver multibeam data and bins the values for length,
%   height, and flow depth using a specified bin size. It computes means 
%   and percentiles (5, 25, 50, 75, 95) within each bin for further analysis.
%
%   BINDATA(BINSIZE, DATASTRUCTURE) takes in the bin size BINSIZE for 
%   discretization and the filename DATASTRUCTURE to a file containing the 
%   river data. BINSIZE default is 0.1 and DATASTRUCTURE default is 
%   the MoRiver structure "MoRiverMultibeamData.mat".
%
%   Other Functions Referenced:
%       load(...), cell2mat(...), max(...), min(...), ceil(...), floor(...),
%       repmat(...), discretize(...), accumarray(...), prctile(...), isnan(...),
%       fieldnames(...), isfield(...), length(...), mean(...), struct(...),
%       numel(...)
%
%
%   -- Matthew Free 07/2025 --

%% Arguments
    arguments
        binSize double = 0.1
        dataStructure string = "MoRiverMultibeamData.mat"
    end

%% Get Data
    load(dataStructure)

    AllRMS = [];
    AllLs = [];
    AllHs = [];
    Allhs = [];
    AllDates = [];
    AllFilenames = [];
    AllQ = [];
    AllStats = [];

    for i = 1:length(MoRiverData)
        RM = cell2mat(MoRiverData(i).ProfileRiverMile);
        L = MoRiverData(i).L;
        H = MoRiverData(i).H;
        h = MoRiverData(i).h;

        
            maxRM = max(RM);
            minRM = min(RM);
        
            maxRMRounded = ceil(maxRM * 10) / 10;
            minRMRounded = floor(minRM * 10) / 10;
        
            if minRM > minRMRounded
                minRMRounded = minRMRounded + 0.1;
            end
        
            bins = minRMRounded:binSize:maxRMRounded;
            binEdges = bins(bins < maxRM);
        
            binIndex = discretize(RM, binEdges);
            valid = ~isnan(binIndex);
            RMBin = binEdges(1:end-1)';
            LBin = accumarray(binIndex(valid), L(valid), [length(binEdges)-1, 1], @mean, NaN);
            HBin = accumarray(binIndex(valid), H(valid), [length(binEdges)-1, 1], @mean, NaN);
            hBin = accumarray(binIndex(valid), h(valid), [length(binEdges)-1, 1], @mean, NaN);
            LCell = accumarray(binIndex(valid), L(valid), [length(binEdges)-1, 1], @(x) {x}, {NaN});
            HCell = accumarray(binIndex(valid), H(valid), [length(binEdges)-1, 1], @(x) {x}, {NaN});
        
            percentiles = [5, 25, 50, 75, 95];
            fields = ["L5", "L25", "L50", "L75", "L95"; 
                      "H5", "H25", "H50", "H75", "H95"];
            
            StatData = struct();
            
            for j = 1:numel(percentiles)
                p = percentiles(j);
            
                StatData.(fields(1,j)) = accumarray(binIndex(valid), L(valid), ...
                    [length(binEdges)-1, 1], ...
                    @(x) prctile(x, p), NaN);
            
                StatData.(fields(2,j)) = accumarray(binIndex(valid), H(valid), ...
                    [length(binEdges)-1, 1], ...
                    @(x) prctile(x, p), NaN);
            end

            StatData.L = LCell;
            StatData.H = HCell;
        
        
        AllFilenames = [AllFilenames; repmat(MoRiverData(i).Filename, length(RMBin), 1)];
        AllDates = [AllDates; repmat(MoRiverData(i).Date, length(RMBin), 1)];
        AllRMS = [AllRMS; RMBin];
        AllLs = [AllLs; LBin];
        AllHs = [AllHs; HBin];
        Allhs = [Allhs; hBin];
        AllQ = [AllQ; repmat(MoRiverData(i).Q, length(RMBin), 1)];

        statFields = fieldnames(StatData);
        for f = 1:numel(statFields)
            field = statFields{f};
            if ~isfield(AllStats, field)
                AllStats.(field) = [];
            end
            AllStats.(field) = [AllStats.(field); StatData.(field)];
        end
    end
    
    % fprintf("Max: %s %s %s %s %s %s, Min: %s %s %s %s %s %s", min(AllDates), max(AllRMS), max(AllLs), max(AllHs), max(Allhs), max(AllQ), ...
    %                                                           max(AllDates), min(AllRMS), min(AllLs), min(AllHs), min(Allhs), min(AllQ))
end