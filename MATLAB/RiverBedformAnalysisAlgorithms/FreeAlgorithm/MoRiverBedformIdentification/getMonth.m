function [date1, date2] = getMonth(firstMonth, secondMonth)
% GETMONTH Takes months as strings and returns the index in the data structure
%   GETMONTH allows for access to a specific month of data by converting
%   the string value into an index within the structure.
%
%   [DATE1,~] = GETMONTH(FIRSTMONTH) takes in the string value of the first
%   month FIRSTMONTH and returns the integer index DATE1.
%
%   [DATE1,DATE2] = GETMONTH(FIRSTMONTH,SECONDMONTH) takes in two string
%   values of the first month FIRSTMONTH and the second month SECONDMONTH
%   and returns the integer indices DATE1 and DATE2
%
%   Other Functions Referenced:
%       nargin(...), error(...)
%
%
%   -- Matthew Free 07/2024 --

%% Arguments
    arguments
        firstMonth (1, 1) string {mustBeMember(firstMonth, ["April", "May", "June"])}
        secondMonth (1, 1) string {mustBeMember(secondMonth, ["April", "May", "June"])} = 0
    end

%% Gets Index
    % gets index value for data based on first month requested
        switch firstMonth
            case 'April'
                date1 = 1;
            case 'May'
                date1 = 2;
            case 'June'
                date1 = 3;
            case 'November'
                date1 = 4;
            otherwise
                error('Invalid date');
        end
        if nargin == 1
            date2 = 3;
            return;
        end
    % gets index value for data based on second month requested
        switch secondMonth
            case 'April'
                date2 = 1;
            case 'May'
                date2 = 2;
            case 'June'
                date2 = 3;
            case 'November'
                date2 = 4;
            otherwise
                error('Invalid date');
        end
end