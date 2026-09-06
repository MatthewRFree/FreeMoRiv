function [X, Y] = curveSmoothing(x, y, n, m)
% CURVESMOOTHING Smooths input x and y data
%   CURVESMOOTHING uses cubic interpolation to smooth noisy data, returning
%   smoothed vectors from the input data.
%
%   [X,Y] = CURVESMOOTHING(X,Y) takes vectors X and Y as arguments and
%   performs cubic interpolation twice returning smooth vectors X and Y.
%   Default values of N and M are 1 and 1 respectively.
%
%   [X,Y] = CURVESMOOTHING(...,N,M) takes values for N and M in addition to
%   X and Y vectors. N and M are scaler parameters that change the level of
%   smoothing, as well as the size and resolution of output vectors X and Y.
%   
%   Other Functions Referenced:
%       unique(...), accumarray(...), numel(...), length(...),
%       linspace(...), spline(...)
%
%
%   -- Matthew Free 07/2024 --

%% Arguments
    arguments
        x double
        y double
        n (1, 1) double = 1
        m (1, 1) double = 1
    end
    
%% Prep Data
    % ensure s and x are stricly increasing
        [x,~,indices] = unique(x); y = accumarray(indices,y,[numel(x) 1],@median);

%% Smooth Data
    % values for x initial and final
        xi = x(1);
        xf = x(end);
    
    % interpolate once to remove noise
        xx = linspace(xi, xf, length(x)/m);
        yy = spline(x,y,xx);
    
    % interpolate a second time to increase resolution
        X = linspace(xi, xf, length(x)*n);
        Y = spline(xx, yy, X);
end