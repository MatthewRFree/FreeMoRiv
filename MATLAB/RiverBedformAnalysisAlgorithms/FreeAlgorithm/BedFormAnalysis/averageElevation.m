function averageElevation(month1, month2, y1, y2)
% AVERAGEELEVATION Compute and print the average elevation of two months.
%   AVERAGEELEVATION calculates the mean elevation for each month and 
%   prints the result.
%
%   AVERAGEELEVATION(MONTH1,MONTH2,Y1,Y2) takes month names MONTH1 and
%   MONTH2 and corresponding elevation data Y1 and Y2 to compute and display
%   their average elevations in feet.
%
%   Other Functions Referenced:
%       mean(...), fprintf(...)
%
%
% -- Matthew Free 06/2024 --

%% Arguments
    arguments
        month1 string
        month2 string
        y1 double {mustBeVector}
        y2 double {mustBeVector}
    end

%% Print
    fprintf("The average elevation for %s was: %.3f (ft).\nThe average elevation for %s was: %.3f (ft).\n", month1, mean(y1), month2, mean(y2));
end