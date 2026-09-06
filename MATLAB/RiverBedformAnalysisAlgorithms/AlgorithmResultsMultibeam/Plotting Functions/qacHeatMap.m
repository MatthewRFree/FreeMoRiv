function [figureHandle1] = qacHeatMap(Eastings, Northings, Color, gridspacing, type, xBoundary, yBoundary)
% HEATMAP Plots dune height and length in respective coordinate locations
%   HEATMAP allows for visualization of dune scales from multibeam
%   bathymetric data.
%
%   HEATMAP(Eastings, Northings, Color) plots the height and length of
%   each dune Color against the coordinate location Easting and
%   Northing.
%
%   HEATMAP(..., gridspacing) changes the dimension of the interpolation
%   grid. A default value of 500 is set.
%
%   HEATMAP(..., type) changes the string label for plotting.
%
%   [FIGUREHANDLE1] = HEATMAP(...) returns the figure handles associated with 
%   each figure.
%
%   Other Functions Referenced:
%       linspace(...), min(...), max(...), meshgrid(...),
%       scatteredInterpolant(...), boundary(...), inpolygon(...),
%       figure(...), imagesc(...), axis(), colorbar(), xlabel(...), ylabel(...),
%       title(...), set(...), ,clim(...)
%
%
%   -- Matthew Free 05/2025 --

%% Arguments
    arguments
        Eastings double
        Northings double
        Color double
        gridspacing double {mustBeInRange(gridspacing, 1, 1000)} = 500
        type string = "Length"
        xBoundary = [];
        yBoundary = [];
    end

%% Interpolate Data

    % Create evenly spaced vectors and create a grid
    xlinspace = linspace(min(Eastings), max(Eastings), gridspacing);
    ylinspace = linspace(min(Northings), max(Northings), gridspacing);
    [grid_X, grid_Y] = meshgrid(xlinspace, ylinspace);

    % Create scatteredInterpolant Object, Natural Interpolation, No Extrapolation
    scatteredInterpolantC = scatteredInterpolant(Eastings, Northings, Color, 'natural', 'none');

    % Apply the scatteredInterpolant to the grid
    interpolatedC = scatteredInterpolantC(grid_X, grid_Y);

    % Use alphaShape to capture external edges and internal holes
    shp = alphaShape(Eastings, Northings, 25);
    insideMask = inShape(shp, grid_X, grid_Y);

    % Mask out invalid interpolated values
    interpolatedC(~insideMask) = NaN;

%% Plot Data

    imagesc(xlinspace, ylinspace, interpolatedC);
    hold on;
    axis xy equal tight
    daspect([1,1,1])
    set(gca, 'Color', 'w');
    hImg = findobj(gca, 'Type', 'Image');
    set(hImg, 'AlphaData', ~isnan(interpolatedC));
    c = colorbar;
    clim([prctile(Color, 2.5), prctile(Color, 97.5)])
    xlabel('Eastings (m)');
    ylabel('Northings (m)');
    title(sprintf('Interpolated %s (m)', type));
    c.Label.String = sprintf('%s (m)',type);
    
    if (~(isempty(xBoundary) || isempty(yBoundary)))
        step = 1;
        xSampled = xBoundary(1:step:end);
        ySampled = yBoundary(1:step:end);

        boundaryIndex = boundary(xSampled, ySampled, 0.5);
        plot(xSampled(boundaryIndex), ySampled(boundaryIndex), 'k-', 'LineWidth', 2);
    end
end