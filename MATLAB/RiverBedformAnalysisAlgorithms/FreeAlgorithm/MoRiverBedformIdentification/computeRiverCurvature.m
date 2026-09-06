function curvature = computeRiverCurvature(eastings, northings)
% COMPUTERIVERCURVATURE Computes river curvature from easting and northing coordinates.
%   COMPUTERIVERCURVATURE estimates the signed curvature based on first 
%   and second derivatives.
%
%   CURVATURE = COMPUTERIVERCURVATURE(EASTINGS,NORTHINGS) computes the 
%   signed curvature defined by EASTINGS and NORTHINGS using interpolation 
%   and gradient methods. The result is downsampled to match the original resolution.
%
%   Other Functions Referenced:
%       diff(...), cumsum(...), linspace(...), pchip(...), gradient(...),
%       sqrt(...), sum(...), length(...)
%
%
% -- Matthew Free 07/2025 --

%% Arguments
    arguments
        eastings double
        northings double
    end

%% Calculate Curvature Values
    % Variables
        upsampleFactor = 250;
        n = length(eastings);
        N = n * upsampleFactor;

    % Combine to matrix
        coordinates = [eastings(:), northings(:)];
    % Pythagorean theorem
        ds = sqrt(sum(diff(coordinates).^2, 2));
        s = [0; cumsum(ds)];

    % Upsample and interpolate using pchip
        sUpsampled = linspace(0, s(end), N);
        eastingUpsampled = pchip(s, eastings, sUpsampled);
        northingUpsampled = pchip(s, northings, sUpsampled);

    % First and second derivative vectors
        dx = gradient(eastingUpsampled, sUpsampled);
        dy = gradient(northingUpsampled, sUpsampled);
        ddx = gradient(dx, sUpsampled);
        ddy = gradient(dy, sUpsampled);

    % Compute signed curvature (Limaye 2025 Eq. 2)
        numerator = dx .* ddy - dy .* ddx;
        denominator = (dx.^2 + dy.^2).^(3/2);
        curvatureUpsampled = numerator ./ denominator;

    % Downsample curvature back to original resolution
        sDownsampled = linspace(0, s(end), n);
        curvature = pchip(sUpsampled, curvatureUpsampled, sDownsampled);
end