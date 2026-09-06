function riverMile = getRiverMileFromCoordInterpolated(Easting, Northing, resolution, searchRadius)
% GETRIVERMILEFROMCOORDINTERPOLATED gets the River Mile value from a coordinate
%   GETRIVERMILEFROMCOORDINTERPOLATED takes an Easting and Northing
%   coordinate and interpolates a database to find the closest River Mile.
%
%   RIVERMILE = GETRIVERMILEFROMCOORDINTERPOLATED(EASTING,NORTHING) takes
%   an Easting and a Northing value EASTING and NORTHING given by the NAD
%   1983 Zone 15 coordinate system and returns the associated closest River
%   Mile RIVERMILE.
%
%   [...] = GETRIVERMILEFROMCOORDINTERPOLATED(...,RESOLUTION) takes a
%   specified resolution to interpolate the database with. By default it is
%   interpolated every 0.01 Miles.
%
%   Other Functions Referenced:
%       load(...), min(...), max(...), interp1(...), sqrt(...)
%
%
% -- Matthew Free 06/2025 --


%% Arguments
    arguments
        Easting double
        Northing double
        resolution double
        searchRadius double = 500;
    end

%% Load DataBase
    persistent T

    if isempty(T)
        load("RiverMileCoordinates.mat", "T");
    end
    
    Easting = Easting(:);
    Northing = Northing(:);
    n = length(Easting);
    riverMile = NaN(n,1);

    for i = 1:n
        x0 = Easting(i);
        y0 = Northing(i);

        % Compute bounding box
        buffer = searchRadius; % in the same units as T.Easting/Northing (e.g., feet)
        inRange = abs(T.Easting - x0) < buffer & abs(T.Northing - y0) < buffer;

        % Skip if no nearby points
        if ~any(inRange)
            warning("No river data near point (%f, %f)", x0, y0);
            continue;
        end

        % Subset and interpolate only near this point
        mileSub = T.RiverMile(inRange);
        xSub = T.Easting(inRange);
        ySub = T.Northing(inRange);

        mileInterp = (min(mileSub):resolution:max(mileSub))';
        xInterp = interp1(mileSub, xSub, mileInterp, 'pchip');
        yInterp = interp1(mileSub, ySub, mileInterp, 'pchip');

        % Compute distance to interpolated points
        dx = xInterp - x0;
        dy = yInterp - y0;
        distances = sqrt(dx.^2 + dy.^2);

        % Find minimum distance point
        [~, idx] = min(distances);
        riverMile(i) = mileInterp(idx);
    end
end
