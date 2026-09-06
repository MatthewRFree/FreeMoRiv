function [X, Y] = map(x, y, frequency, xStart, xLength)
% MAP maps input x and y data
%   MAP uses linear interpolation to both increase resolution and ensure
%   that each discrete point is equally spaced in the x domain
%
%   [X,Y] = MAP(X,Y,FREQUENCY,XSTART,XLENGTH) takes in vectors X and Y as
%   arguments and maps the data from XSTART for a distance XLENGTH at a
%   sampling frequency of FREQUENCY. XSTART and XLENGTH are measured in
%   miles, and FREQUENCY is miles^-1. This function returns the mapped data
%   vectors X and Y.
%
%   Other Functions Referenced:
%       unique(...), accumarray(...), numel(...), length(...),
%       linspace(...), isempty(...), interp1(...)
%
%
%   -- Matthew Free 07/2024 --

%% Arguments
    arguments
        x double
        y double
        frequency (1, 1) double
        xStart (1, 1) double
        xLength (1, 1) double
    end

%% Prep Data
    % ensures all values of X are unique so that interpolation can be performed
        [x,~,indices] = unique(x); y = accumarray(indices,y,[numel(x) 1],@median);

%% Map Data
    % create map vector
        X = linspace(xStart, xStart + xLength, xLength/frequency);
    
    % map x and y to the created vector
        if ~isempty(x)
            Y = interp1(x, y, X, "linear");
    
    % handle errors from empty vectors
        else
            X = 0;
            Y = 0;
        end
end

