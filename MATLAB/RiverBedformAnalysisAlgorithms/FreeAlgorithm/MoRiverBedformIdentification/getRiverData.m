function [x1, y1, x2, y2] = getRiverData(data, xStart, xLength, firstMonth, axis, secondMonth, frequency, type, ox)
% GETRIVERDATA Gets data for specified months and returns the mapped x and y vectors
%   GETRIVERDATA allows for easy access of data from the data structure
%   specifying various parameters such as the months, start, length, and
%   frequency of the data.
%
%   [X1,Y1] = GETRIVERDATA(DATA,XSTART,XLENGTH) takes in the data
%   structure DATA and scalers XSTART and XLENGTH to specify the starting
%   mile and mile length of data requested. Uses 'May' as the default
%   FIRSTMONTH, '' for SECONDMONTH, 0.00001 FREQUENCY, 'Center' AXIS, 'x'
%   TYPE, and 0.1 OX.
%
%   [X1,Y1] = GETRIVERDATA(...,FIRSTMONTH) returns data for the
%   specified first month FIRSTMONTH.
%
%   [...] = GETRIVERDATA(...,FIRSTMONTH,AXIS) returns the data for the
%   requested axis AXIS. AXIS can either be 'Left', 'Center', or 'Right'.
%
%   [X1,Y1,X2,Y2] = GETRIVERDATA(...,FIRSTMONTH,AXIS,SECONDMONTH) returns data
%   for both months specified FIRSTMONTH and SECONDMONTH.
%
%   [...] = GETRIVERDATA(...,FREQUENCY) returns the data for the requested
%   frequency sample rate FREQUENCY. FREQUENCY is measured in miles^-1.
%   FREQUENCY of -1 will result in returned raw unmapped data.
%
%   [...] = GETRIVERDATA(...,TYPE) returns the data for the requested type
%   TYPE. TYPE can either be 'o' for the offsets or 'x' for the river miles
%
%   [...] = GETRIVERDATA(...,OX) returns the data with a requested offsetX
%   value OX. OX gets extra data to prevent NaN values on the ends of the
%   data from interpolation.
%
%   [X1,Y1,X2,Y2] = GETRIVERDATA(...) returns X1 and Y1 which are vectors
%   cooresponding to the first month requested. X2 and Y2 are vectors
%   corresponding to the second month requested. X values are in miles and
%   Y values are in feet.
%
%   Other Functions Referenced:
%       strcmp(...), getMonth(...), find(...), map(...)
%
%
%   -- Matthew Free 07/2024 --

%% Arguments
    arguments
        data
        xStart (1, 1) double {mustBeInRange(xStart, 100, 145)}
        xLength (1, 1) double {mustBeInRange(xLength, 0.001, 35.001)}
        firstMonth (1, 1) string {mustBeMember(firstMonth, ["April", "May", "June"])} = "May";
        axis (1, 1) string {mustBeMember(axis, ["Center", "Left", "Right"])} = "Center";
        secondMonth (1, 1) string {mustBeMember(secondMonth, ["April", "May", "June"])} = 'June';
        frequency (1, 1) double {mustBeInRange(frequency, -1.1, 1.1)} = 0.00001;
        type (1, 1) char {mustBeMember(type, ["x", "o", "w"])} = 'x';
        ox (1, 1) double {mustBeInRange(ox, -0.1, 1)} = 0.1;
    end
%% Get Data
    % Gets indices for each month
        if ~strcmp('', secondMonth)
            [date1, date2] = getMonth(firstMonth, secondMonth);
        else
            [date1, date2] = getMonth(firstMonth);
        end
    
    % Assigns values to y1 and y2 based on specified axis and type
        if type == 'x'
            switch axis
                case 'Center'
                    y1 = data(date1).Center.z;
                    x1 = data(date1).Center.x;
                    y2 = data(date2).Center.z;
                    x2 = data(date2).Center.x;
                case 'Left'
                    y1 = data(date1).Left.z;
                    x1 = data(date1).Left.x;
                    y2 = data(date2).Left.z;
                    x2 = data(date2).Left.x;
                case 'Right'
                    y1 = data(date1).Right.z;
                    x1 = data(date1).Right.x;
                    y2 = data(date2).Right.z;
                    x2 = data(date2).Right.x;
                otherwise
                    error('Invalid Axis')
            end
        elseif type == 'o'
            switch axis
                case 'Center'
                    y1 = data(date1).Center.offset;
                    x1 = data(date1).Center.x;
                    y2 = data(date2).Center.offset;
                    x2 = data(date2).Center.x;
                case 'Left'
                    y1 = data(date1).Left.offset;
                    x1 = data(date1).Left.x;
                    y2 = data(date2).Left.offset;
                    x2 = data(date2).Left.x;
                case 'Right'
                    y1 = data(date1).Right.offset;
                    x1 = data(date1).Right.x;
                    y2 = data(date2).Right.offset;
                    x2 = data(date2).Right.x;
                otherwise
                    error('Invalid Axis')
            end
        elseif type == 'w'
            switch axis
                case 'Center'
                    y1 = data(date1).Center.waterElevation;
                    x1 = data(date1).Center.x;
                    y2 = data(date2).Center.waterElevation;
                    x2 = data(date2).Center.x;
                case 'Left'
                    y1 = data(date1).Left.waterElevation;
                    x1 = data(date1).Left.x;
                    y2 = data(date2).Left.waterElevation;
                    x2 = data(date2).Left.x;
                case 'Right'
                    y1 = data(date1).Right.waterElevation;
                    x1 = data(date1).Right.x;
                    y2 = data(date2).Right.waterElevation;
                    x2 = data(date2).Right.x;
                otherwise
                    error('Invalid Axis')
            end
        else
            error('Invalid Type')
        end
%% Map Data
    % finds the indices between function arguments for the first and second dates
        indices1 = find(x1 >= xStart - ox & x1 <= (xStart + xLength + ox));
        indices2 = find(x2 >= xStart - ox & x2 <= (xStart + xLength + ox));
    
    % sets values of y1 and y2 at specified indices
        y1 = y1(indices1);
        y2 = y2(indices2);
        x1 = x1(indices1);
        x2 = x2(indices2);
    
    % maps each vector so they are aligned and share the same length
        if frequency < 0
            return;
        else
            [x1, y1] = map(x1, y1, frequency, xStart, xLength);
            [x2, y2] = map(x2, y2, frequency, xStart, xLength);
        end
end

