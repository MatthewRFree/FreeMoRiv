function figureHandle = elevationMap(Eastings, Northings, Elevation, markerSize)
% ELEVATIONMAP Plots an elevation scatter map for Eastings and Northings.
%   ELEVATIONMAP allows for visualization of the riverbed to compare with
%   the heamap of dune scales.
%
%   ELEVATIONMAP(EASTINGS, NORTHINGS, ELEVATION) plots the elevation ELEVATION at
%   each given easting EASTINGS and northing NORTHINGS coordinate value.
%
%   ELEVATIONMAP(..., MARKERSIZE) plots with a given scatter point size
%   MARKERSIZE.
%
%   FIGUREHANDLE = ELEVATIONMAP(...) returns the handle to the figure.
%
%   Other Functions Referenced:
%       figure(...), scatter(...), title(...), xlabel(...), ylabel(...)
%
%
%   -- Matthew Free 06/2025 --


%% Arguments
    arguments
        Eastings double
        Northings double
        Elevation double
        markerSize double {mustBeInRange(markerSize, 1, 100)} = 10
    end

%% Plot Data
    figureHandle = figure("Name","Bed Elevation Profiles - NAD 1983 Zone 15");
        scatter(Eastings, Northings, markerSize, Elevation, '.');
        title("Bed Elevation Profiles - NAD 1983 Zone 15")
        xlabel("Eastings (m)")
        ylabel("Northings (m)")
        axis equal
        daspect([1,1,1])
        c = colorbar;
        c.Label.String = 'Elevation (m)';
end