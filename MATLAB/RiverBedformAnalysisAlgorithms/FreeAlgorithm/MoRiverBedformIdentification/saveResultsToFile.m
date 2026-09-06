function saveResultsToFile(xStart, xLength, month1, parameters, smoothX, smoothY, pPeaks, pTroughs, sPeaks, sTroughs, primaryHeight, secondaryHeight, primaryLength, secondaryLength, algorithm, Axis)
% SAVERESULTSTOFILE Saves results from the previous run
%   SAVERESULTSTOFILE saves the specified variables required in the
%   PLOTDUNEHEIGHTLENGTH function with a unique file name in the .mat
%   format. Saves the resulting figures in the .fig format.
%
%   SAVERESULTSTOFILE(XSTART,XLENGTH,MONTH1,PARAMETERS,SMOOTHX,SMOOTHY,PPEAKS,
%                     PTROUGHS,SPEAKS,STROUGHS,PRIMARYHEIGHT,SECONDARYHEIGHT,
%                     PRIMARYLENGTH,SECONDARYLENGTH,ALGORITHM,AXIS) takes in XSTART, 
%   XLENGTH, and MONTH1 as arguments to create a unique filename. SMOOTHX, 
%   SMOOTHY, PPEAKS, PTROUGHS, SPEAKS, STROUGHS, PRIMARYHEIGHT, SECONDARYHEIGHT, 
%   PRIMARYLENGTH, and SECONDARYLENGTH are vectors specifying the heights, 
%   lengths, and indices of peaks and troughs. PARAMETERS is a variable of any 
%   type specifying the parameters used to obtain the results, preferably a
%   struct with the field name as the variable name and the field
%   containing the value. ALGORITHM is a string used to specify the
%   correct path, separting results into directories by ALGORITHM: Free,
%   Zomer, Scheiber. AXIS is a string used to specify which AXIS was used
%   to separate results when saved to file
%
%   Other Functions Referenced:
%       addpath(...), sprintf(...), findall(...), isfile(...), save(...),
%       savefig(...)
%
%
%   -- Matthew Free 07/2024 --

%% Arguments
    arguments
        xStart (1, 1) double {mustBeInRange(xStart, 100, 145)}
        xLength (1, 1) double {mustBeInRange(xLength, 0.001, 35.001)}
        month1 (1, 1) string {mustBeMember(month1, ["April", "May", "June"])}
        parameters (:,1) struct
        smoothX (:,1) double
        smoothY (:,1) double
        pPeaks (:,1) double
        pTroughs (:,1) double
        sPeaks (:,1) double
        sTroughs (:,1) double
        primaryHeight (:,1) double
        secondaryHeight (:,1) double
        primaryLength (:,1) double
        secondaryLength (:,1) double
        algorithm (1, 1) string {mustBeMember(algorithm, ["Free", "Zomer", "Scheiber"])} = "Free"
        Axis (1, 1) string {mustBeMember(Axis, ["Center", "Left", "Right"])} = "Center"
    end

%% Prep Data
    % Create specified path
        path = sprintf('..//AlgorithmResultsSinglebeam/%sAlgorithm/', algorithm);
        addpath(path);
        
    % Create filenames for data and figures
        dataFileName = sprintf('%s%sRiverMile%d-%dData.mat', month1, Axis, xStart, xStart+xLength);
        avgFileName = sprintf('%s%sRiverMile%d-%dAVG.mat', month1, Axis, xStart, xStart+xLength);
        figureFileName = sprintf('%s%sRiverMile%d-%dFigure.fig', month1, Axis, xStart, xStart+xLength);
        histogramFileName = sprintf('%s%sRiverMile%d-%dHistogram.fig', month1, Axis, xStart, xStart+xLength);
        
    % Get the figure handles
        figureHandles = findall(0, 'Type', 'figure');

%% Save Data
    % Save the data variables
        if ~isfile([path, dataFileName])
            save([path, dataFileName], "parameters", "smoothX", "smoothY", "pPeaks", "pTroughs", "primaryHeight", "secondaryHeight", "primaryLength", "secondaryLength", "sPeaks", "sTroughs");
        end
    
    % Save the peaks and troughs figure
        if ~isfile([path, figureFileName])
            savefig(figureHandles(2), [path, figureFileName]);
        end
    
    % Save the histogram
        if ~isfile([path, histogramFileName])
            savefig(figureHandles(1), [path, histogramFileName]);
        end
    
    % Save the averages
        if ~isfile([path, avgFileName])
            structName = sprintf('%s%sRiverMile%d_%dAVG', month1, Axis, xStart, xStart+xLength);
            eval(sprintf("%s = struct('averagePrimaryLength', mean(primaryLength), 'averageSecondaryLength', mean(secondaryLength), 'averagePrimaryHeight', mean(primaryHeight), 'averageSecondaryHeight', mean(secondaryHeight));", structName));
            eval(sprintf("save('%s%s', '%s');", path, avgFileName, structName));
        end
end