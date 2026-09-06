function [x, yo] = derivative(x, y)
% DERIVATIVE Discretely differentiates y with respect to x
%   DERIVATIVE uses discrete slope based approach to differentiate and
%   return x and yo where f(x) = y and f'(x) = yo.
%
%   [X,Yo] = DERIVATIVE(X,Y) takes vectors X and Y and computes the slope
%   Y/X at each point returning the vector X and slope vector Yo.
%
%   Note: Yo and Y are the same size as the first point is assumed to be
%   linear i.e. Yo(1) = Yo(2). Each differentiation results in a loss of
%   resolution.
%
%   Other Functions Referenced:
%       length(...)
%
%
%   -- Matthew Free 07/2024 --

%% Arguments
    arguments
        x double
        y double
    end

%% Prep Data
    if length(y) ~= length(x)
        error("Array sizes must be equal!");
    end

%% Calculate Derivative
    for i = 2:length(y)
        yo(i) = (y(i)-y(i-1))/(x(i)-x(i-1));
    end
    yo(1) = yo(2);
end