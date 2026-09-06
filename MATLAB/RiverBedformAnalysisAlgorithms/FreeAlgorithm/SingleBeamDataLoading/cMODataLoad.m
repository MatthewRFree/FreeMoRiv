classdef cMODataLoad
    properties
        MODataCenter; % data from center sheet
        MODataLeft; % data from left sheet
        MODataRight; % data from right sheet
    end
    methods
         % imports data to table from spreadsheet
         % requires a specified file and sheet name
        function obj = cMODataLoad()
            obj.MODataCenter = importData("MoRiverData (Raw).xlsx", "Center");
            obj.MODataLeft = importData("MoRiverData (Raw).xlsx", "Left");
            obj.MODataRight = importData("MoRiverData (Raw).xlsx", "Right");
        end
        % initializes the struct and assigns values based on table
        % requires the raw data from the function above
        % requires specified sheet separating by right, left, or center
        % requires an integer n separating by date
        function MoRiverData = makeStruct(rawData, sheet, n)
            MoRiverData = struct;

            if strcmp(sheet,"Center")
                x = rawData.MODataCenter(n).x{:, 1};
                z = rawData.MODataCenter(n).z{:, 1};
                offset = rawData.MODataCenter(n).offset{:, 1};
                waterElevation = rawData.MODataCenter(n).waterElevation{:, 1};
                date = rawData.MODataRight(n).date;

            elseif strcmp(sheet,"Left")
                x = rawData.MODataLeft(n).x{:,1};
                z = rawData.MODataLeft(n).z{:,1};
                offset = rawData.MODataLeft(n).offset{:,1};
                waterElevation = rawData.MODataLeft(n).waterElevation{:,1};
                date = rawData.MODataRight(n).date;

            elseif strcmp(sheet,"Right")
                x = rawData.MODataRight(n).x{:,1};
                z = rawData.MODataRight(n).z{:,1};
                offset = rawData.MODataRight(n).offset{:,1};
                waterElevation = rawData.MODataRight(n).waterElevation{:,1};
                date = rawData.MODataRight(n).date;

            end
            MoRiverData.x = x;
            MoRiverData.z = z;
            MoRiverData.offset = offset;
            MoRiverData.waterElevation = waterElevation;
            MoRiverData.date = date;
        end
    end
end