clear
clc
close all

addpath("..\..\..\..\Multibeam Data\MoRiver\ExcelSpreadsheets\")
addpath("..\..\..\..\Multibeam Data\MoRiver\OutputMATLABFiles\")
addpath("..\MoRiverBedformIdentification\")

%% Get File Names
% Excel File to Read
    ouputPath = "..\..\..\..\Multibeam Data\MoRiver\OutputMATLABFiles\";
    inputPath = "..\..\..\..\Multibeam Data\MoRiver\ExcelSpreadsheets\";

    fileNames = getFilenames(inputPath);

%% Export Data
    for k = 1:length(fileNames)
        filename = fileNames(k);

        pieces = filename.split(".");
        basename = pieces(1);
    
    % Create table from File
        T = readtable(filename);
        
        if length(unique(T.ORIG_FID)) > 12
            for i=1:max(unique(T.ORIG_FID))
                % Create mask for which values to pull
                    mask = T.ORIG_FID == i;
                
                if sum(mask) ~= 0
                    % Create variables for Eastings, Northings, and Depths.
                        if (isstring(T.POINT_X(1)))
                            Easting_values = str2double(T.POINT_X(mask)); %(meters)
                            Northing_values = str2double(T.POINT_Y(mask)); %(meters)
                            Depth_values = str2double(T.POINT_Z(mask)); %(feet)
                        else
                            Easting_values = T.POINT_X(mask); %(meters)
                            Northing_values = T.POINT_Y(mask); %(meters)
                            Depth_values = T.POINT_Z(mask); %(feet)
                        end
                    
                        lengths = sqrt(diff(Easting_values - min(Easting_values)).^2 + diff(Northing_values - min(Northing_values)).^2);
                        avg = mean(lengths);
                
                    % Get distance along the curve (m)
                        for j = 1:length(lengths)
                            s(j+1) = sum(lengths(1:j));
                        end
                        s = s';
                
                    % Create psuedo elevation (m)
                        z = 100 + 0.00018939441.*s - 0.3048.*Depth_values;
                    
                        save(sprintf('%s%s%s%d',ouputPath,basename, '_',i), "s", "z", "Easting_values", "Northing_values", "Depth_values");
                    
                    clear s z
                end
            end
            fprintf("Finished: %d/%d\n", k,length(fileNames))
        end
    end