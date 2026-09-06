function [height, slope] = pointSlopeHeight(x1, y1, x2, y2)
% POINTSLOPEHEIGHT computes vertical height of dunes
%   POINTSLOPEHEIGHT calculates the vertical distance between a dune peak
%   and the intersection with the line formed by an inclined slope between
%   the surrounding two troughs. Uses the point slope form equation for
%   calculations.
%
%   [HEIGHT,SLOPE] = POINTSLOPEHEIGHT(X1,Y1,X2,Y2) takes four vectors
%   corresponding to the x and y locations of peaks and troughs. X1 and Y1 
%   must be troughs and X2 and Y2 must be peaks. Returns a vector HEIGHT
%   with each height and a vector SLOPE with the inclined slope betweem troughs.
%   X1 and X2 are measured in miles and Y1 and Y2 are measured in feet.
%
%   Other Functions Referenced:
%       length(...)
%
%
%   -- Matthew Free 07/2024 --

%% Arguments
    arguments
        x1 double
        y1 double
        x2 double
        y2 double
    end

%% Prep Data
    % convert to metric meters
        x1 = x1 * 1609.34;
        x2 = x2 * 1609.34;
        y1 = y1 * 0.305;
        y2 = y2 * 0.305;

%% Test For Trough/Peak/Trough and Compute Height
        height = [];
        slope = [];
        count = 1;

    % loop through all the trough points
    for i = 1:length(x1)-1
        % Find peaks between troughs x1(i) and x1(i+1)
        inRange = x2 > x1(i) & x2 < x1(i+1);
    
        if any(inRange)
        % Use the leading peak
            j = find(inRange, 1, 'first');
    
        %m =    (y2  -  y1)  /  (x2   -   x1)
            m = (y1(i+1)-y1(i)) / (x1(i+1)-x1(i));

        %height    =  y3   -  (y1   +  m (x3  -  x1))
            height(count) = y2(j) - (y1(i) + (m * (x2(j)-x1(i))));
            slope(count) = m;
            count = count + 1;
        end
    end
end

