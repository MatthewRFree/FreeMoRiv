function [number, lengths, heights] = prominenceTest(X, Y, prominence)
% PROMINENCETEST Gets bedform characteristics from x y vectors for analysis 
%   PROMINENCETEST allows for quick and easy testing of the prominence
%   parameter. This function returns the number of dunes, average lengths
%   and heights of dunes associated with a specified value of prominence.
%
%   [NUMBER,LENGTHS,HEIGHTS] = PROMINENCETEST(X,Y) takes vectors X and Y as 
%   arguments and computes the bedform characteristics. A default PROMINENCE 
%   value of 1 is used. A scaler NUMBER is returned with the number of dunes.
%   Two vectors LENGTHS and HEIGHTS are returned specifying the heights and
%   lengths of dunes at a specified prominence.
%
%   [NUMBER,LENGTHS,HEIGHTS] = PROMINENCETEST(X,Y) takes vectors X and Y as
%   arguments as well as a specified PROMINENCE value. A higher PROMINENCE
%   value filters out smaller BEDFORM characteristics.
%
%   Other Functions Referenced:
%       findpeaks(...), pythagoreanTheorem(...), pointSlopeHeight(...),
%       length(...)
%
%
%   -- Matthew Free 07/2024 --

%% Arguments
    arguments
        X double
        Y double
        prominence (1, 1) double = 1;
    end

%% Get Peaks and Troughs
    % Peaks
        [peaks, peakIndices] = findpeaks(Y, "MinPeakProminence",prominence);
    
    % Troughs
        [troughs, troughIndices] = findpeaks(-Y, "MinPeakProminence",prominence);

%% Calculate Dune Heights and Lengths
    % Inclined Length
        lengths = pythagoreanTheorem(X(troughIndices), -troughs);
    
    % Vertical Height
        heights = pointSlopeHeight(X(troughIndices), -troughs, X(peakIndices), peaks);

    % Number of Dunes at Prominence Value
        number = length(lengths);
end

