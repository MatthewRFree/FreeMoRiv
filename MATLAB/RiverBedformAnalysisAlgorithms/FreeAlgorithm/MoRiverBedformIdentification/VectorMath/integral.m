function [S, area] = integral(x, y)
% INTEGRAL Discretely integrates y with respect to x
%   INTEGRAL uses trapezoidal method to integrate and return the total sum
%   and a vector of sums
%
%   [S,AREA] = DERIVATIVE(X,Y) takes vectors X and Y and computes the
%   trapezoidal area at each point returning the total sum S and a vector
%   containing each trapezoid area AREA.
%
%   Other Functions Referenced:
%       length(...), zeros(...)
%
%
%   -- Matthew Free 07/2024 --

%% Arguments
    arguments
        x double
        y double
    end

%% Calculate Integral
    area = zeros(length(x)-1, 1);
    for i = 1:length(x) - 1
        dx = (x(i+1)-x(i))*5280; % dx convert from miles to feet
        area(i) = 0.5*(y(i) + y(i+1))*(dx);
    end
    S = sum(area);
end

