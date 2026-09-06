function [lengthStoss, lengthLee, heightStoss, heightLee] = duneStossAndLee(x1, y1, x2, y2)
% DUNESTOSSANDLEE Calculates the stoss and lee values from x1, y1, x2, y2
%   DUNESTOSSANDLEE calculates the horizontal length and vertical height of
%   the stoss and lee formed from the leading trough and peak as well as
%   the peak and lagging trough.
%
%   [...] = DUNESTOSSANDLEE(X1,Y1,X2,Y2) takes four vectors corresponding to 
%   the x and y locations of peaks and troughs. X1 and Y1 must be troughs 
%   and X2 and Y2 must be peaks. X1 and X2 are measured in miles and Y1 and 
%   Y2 are measured in feet.
%
%   [LENGTHSTOSS,LENGTHLEE,HEIGHTSTOSS,HEIGHTLEE] = DUNESTOSSANDLEE(...)
%   returns the vectors LENGTHSTOSS which are the stoss lengths, LENGTHLEE
%   which are the lee lengths, HEIGHTSTOSS which are the stoss heights, and
%   HEIGHTLEE which are the lee heights.
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

%% Test For Trough/Peak/Trough and Compute Stoss/Lee
    lengthStoss = [];
    lengthLee = [];
    heightStoss = [];
    heightLee = [];
    count = 1;

    for i = 1:length(x1)-1
        % Find peaks between troughs x1(i) and x1(i+1)
        inRange = x2 > x1(i) & x2 < x1(i+1);
    
        if any(inRange)
        % Use the leading peak
            j = find(inRange, 1, 'first');
    
        % gets the stoss length and height
            lengthStoss(count) = x1(i+1) - x2(j);
            heightStoss(count) = y2(j) - y1(i+1);
    
        % gets the lee length and height
            lengthLee(count) = x2(j) - x1(i);
            heightLee(count) = y2(j) - y1(i);
        
            count = count + 1;
        end
    end
end

