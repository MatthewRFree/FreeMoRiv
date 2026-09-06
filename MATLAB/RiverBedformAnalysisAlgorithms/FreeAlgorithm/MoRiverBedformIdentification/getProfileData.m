function Data = getProfileData(filename, thresholdHPF, primaryProminence)
% GETPROFILEDATA Gathers and transforms  profile data.
%   GETPROFILEDATA takes a spcified file and gathers the data
%   corresponding to that file. 
%
%   DATA = GETPROFILEDATA(FILENAME) takes the specified file FILENAME
%   and returns the data structure DATA. A default THRESHOLDHPF or the 
%   maximum high pass filter value of 50 is set. A default value of 0.1 is 
%   set for the prominence PRIMARYPROMINENCE.
%   
%   DATA = GETPROFILEDATA(..., THRESHOLDHPF, PRIMARYPROMINENCE) takes a
%   maximum high pass filter value THRESHOLDHPF and a prominence value
%   PRIMARYPROMINENCE as arguments.
%
%   FILENAME is a MATLAB .mat file containing the following variables:
%       Depth_values: Depths
%       Easting_values: Eastings
%       Northing_values: Northings
%       s: Distance along the profile
%       z: Height at each point along the profile
%
%   DATA is a struct containing the following fields:
%       EASTINGS: all profile's easting coordinates
%       NORTHINGS: all profile's northing coordinates
%       DEPTHS: all profile's depth values
%       ELEVATION: all profile's psuedo elevation values
%       DUNEEASTINGS: all profile's easting coordinates at dune locations
%       DUNENORTHINGS: all profile's northing coordinates at dune locations
%       DUNEDEPTHS: all profile's depth values at dune locations
%       C1: all profile's dune heights
%       C2: all profile's dune lengths
%       PROPSPRIM: vector of PROPSPRIM data structures
%       PRIMARYLENGTH: cell array of dune lengths for each profile
%       PRIMARYHEIGHT: cell array of dune heights for each profile
%       PPEAKS: cell array of dune peak indices for each profile
%       PTROUGHS: cell array of dune trough indices for each profile
%       AVGLENGTHS: vector of overall average dune length for each profile
%       PROMINENCE: vector of prominence values used for each profile
%
%   Other Functions Referenced:
%       exist(...), load(...), strcat(...), num2str(...), length(...),
%       getSprofileInterp(...), getWtHPF(...), isempty(...), min(...),
%       diff(...), isrow(...), mean(...), curveSmoothing(...), duneHeightLength(...)
%
%
% -- Matthew Free 05/2025 --

%% Arguments
    arguments
        filename string
        thresholdHPF double = 50
        primaryProminence double = nan;
    end

%% Temporary Variables
    % Order in which each profile line was assigned an ID
        order = [21 19 17 15 13 11 9 7 5 3 1 2 4 6 8 10 12 14 16 18 20];

    % Max allowable Dune Length (m)
         maxLength = thresholdHPF;

    % Empty vectors for initialization
        Data.Eastings = [];
        Data.Northings = [];
        Data.Depths = [];
        Data.Elevation = [];
        Data.duneEastings.troughs = {};
        Data.duneNorthings.troughs = {};
        Data.duneEastings.peaks = {};
        Data.duneNorthings.peaks = {};
        Data.duneTroughDepths = [];
        Data.dunePeakDepths = [];
        Data.c1 = [];
        Data.c2 = [];

%% Get Data
    for i = 1:21
        file = sprintf("%s%s%s%s",filename, "_", num2str(i), ".mat");
        % Load file if it exists
        if exist(file, "file")
            load(file); %#ok<LOAD>
            
            if (length(s) > 50)
            % Save original 3D coordinate values
                Data.Eastings = [Data.Eastings; Easting_values];
                Data.Northings = [Data.Northings; Northing_values];
                Data.Depths = [Data.Depths; Depth_values];
                Data.Elevation = [Data.Elevation; z];

            % Interpolate and use High Pass Filter
                [sInterp, zInterp, Easting_values, Northing_values, Depth_values] = getSprofileInterp(s, z, Easting_values, Northing_values, Depth_values);
                
                mask = createMask(s, sInterp);

                if (~isempty(sInterp))
                    zInterp = getWtHPF(zInterp, min(diff(sInterp)), thresholdHPF);
                    %z = getHPF(z, min(diff(s)), thresholdHPF);

                    if isrow(sInterp); sInterp = sInterp'; end
                    if isrow(zInterp); zInterp = zInterp'; end
                    if isrow(Easting_values); Easting_values = Easting_values'; end
                    if isrow(Northing_values); Northing_values = Northing_values'; end
                    if isrow(Depth_values); Depth_values = Depth_values'; end
    
                % Calculate a Prominence
                    if isnan(primaryProminence)
                       prominence = calculateProminence(sInterp, zInterp);
                    else
                        prominence = primaryProminence;
                    end

                % Convert from meters to feet and miles
                    s_miles = 0.000621371.*sInterp;
                    z_feet = 3.28084.*zInterp;
    
                % Lightly smooth data
                    [smoothS, smoothZ] = curveSmoothing(s_miles, z_feet, 1, 2);

                % Find the Bedform scales
                    props = duneHeightLength(smoothS, smoothZ, prominence);
                    props.Eastings = Easting_values;
                    props.Northings = Northing_values;
                    props.Depths = Depth_values;
                    props.smoothS = smoothS;
                    props.smoothZ = smoothZ;
                    
                    props = maskData(props, mask);

                    Data.propsPrim(i) = props;
                
                % Save values to cell array
                    Data.primaryLength{i} = Data.propsPrim(i).totalLength;  Data.primaryHeight{i} = Data.propsPrim(i).avgHeight;
                    Data.pPeaks{i} = Data.propsPrim(i).peakIndices; Data.pTroughs{i} = Data.propsPrim(i).troughIndices;
                
                % Gathers average length at each transverse location
                    Data.avgLengths(order==i) = mean(Data.propsPrim(i).totalLength(Data.propsPrim(i).totalLength < maxLength));
    
                % Populate values for 2D heatmap using coordinate locations
                    Data.duneEastings.troughs{i,1} = Easting_values(Data.propsPrim(i).troughIndices(1:end));
                    Data.duneNorthings.troughs{i,1} = Northing_values(Data.propsPrim(i).troughIndices(1:end));
                    
                    % Depths at each dune trough
                        Data.duneTroughDepths = [Data.duneTroughDepths; Depth_values(Data.propsPrim(i).troughIndices(1:end-1))];
                    
                    % Depths at each dune peak
                        troughs = Data.propsPrim(i).troughIndices;
                        peaks   = Data.propsPrim(i).peakIndices;
    
                        % Only keep peaks that lie between the first and last trough
                        if ~isempty(troughs)
                            validPeakMask = peaks > troughs(1) & peaks < troughs(end);
                        else
                            validPeakMask = [];
                        end
                        validPeaks = peaks(validPeakMask);
                        
                        % Get depth values at those peak locations
                        Data.dunePeakDepths = [Data.dunePeakDepths; Depth_values(validPeaks)];
                        Data.duneEastings.peaks{i,1} = Easting_values(validPeaks);
                        Data.duneNorthings.peaks{i,1} = Northing_values(validPeaks);
                
                % Save Dune Heights and Lengths
                    Data.c1 = [Data.c1; Data.propsPrim(i).avgHeight'];
                    Data.c2 = [Data.c2; Data.propsPrim(i).totalLength'];
                    Data.Prominence(i) = prominence;
                end
            end
        end
    end
end