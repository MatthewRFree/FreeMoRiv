function c = pythagoreanTheorem(x, y)
% PYTHAGOREANTHEOREM Calculates straight line distance
%   PYTHAGOREANTHEOREM Calculates the inclined length or the straight line
%   distance between each element in an x and y vector.
%
%   C = PYTHAGOREANTHEOREM(X,Y) takes vectors X and Y as arguments and
%   returns a vector of lengths C. X and Y must be trough locations as dune
%   lengths are measured trough to trough. X is measured in miles and Y is
%   measured in feet.
%
%   Other Functions Referenced:
%       length(...), sqrt(...)
%
%
%   -- Matthew Free 07/2024 --

%% Arguments
    arguments
        x double
        y double
    end

%% Calculate Pythagorean Theorem
    % calculate all the differences in height and length
        x = x(1:length(x)-1) - x(2:length(x));
        y = y(1:length(y)-1) - y(2:length(y));
    
    % convert to metric meters
        a = 1609.34.*(x);
        b = 0.305.*(y);
    
    % simple pythagorean theorem
        c = sqrt(a.^2 + b.^2);
end

