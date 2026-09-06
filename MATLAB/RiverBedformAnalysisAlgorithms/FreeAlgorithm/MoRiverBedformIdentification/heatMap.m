function [figureHandle1, figureHandle2] = heatMap(Eastings, Northings, c1, c2, gridspacing)
% HEATMAP Plots dune height and length in respective coordinate locations
%   HEATMAP allows for visualization of dune scales from multibeam
%   bathymetric data.
%
%   HEATMAP(Eastings, Northings, c1, c2) plots the height and length of
%   each dune c1 and c2 against the coordinate location Easting and
%   Northing.
%
%   HEATMAP(..., gridspacing) changes the dimension of the interpolation
%   grid. A default value of 500 is set.
%
%   [FIGUREHANDLE1, FIGUREHANDLE2] = HEATMAP(...) returns the figure
%   handles associated with each figure.
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
        c1 double
        c2 double
        gridspacing double {mustBeInRange(gridspacing, 1, 1000)} = 500
    end

%% Interpolate Data
    % Create evenly spaced vectors and create a grid
        xlinspace = linspace(min(Eastings), max(Eastings), gridspacing);
        ylinspace = linspace(min(Northings), max(Northings), gridspacing);
        [grid_X, grid_Y] = meshgrid(xlinspace, ylinspace);
        
    % Create scatteredInterpolant Object, Natural Interpolation, No Extrapolation
        scatteredInterpolantHeight = scatteredInterpolant(Eastings, Northings, c1, 'natural', 'none');
        scatteredInterpolantLength = scatteredInterpolant(Eastings, Northings, c2, 'natural', 'none');
        
    % Apply the scatteredInterpolant to the grid
        interpolatedC1 = scatteredInterpolantHeight(grid_X, grid_Y);
        interpolatedC2 = scatteredInterpolantLength(grid_X, grid_Y);
        
    % Create a mask of values within the boundary
        boundaryIndices = boundary(Eastings, Northings, 1); 
        insideMask = inpolygon(grid_X, grid_Y, Eastings(boundaryIndices), Northings(boundaryIndices));
    
    % Remove all values outside boundary (Color White)
        interpolatedC1(~insideMask) = NaN;
        interpolatedC2(~insideMask) = NaN;

    % Set Color Thresholds
        maxColorLength = mean(c2)*2;
        maxColorHeight = mean(c1)*2.5;

%% Plot Data
    figureHandle1 = figure;
        imagesc(xlinspace, ylinspace, interpolatedC1);
        axis xy equal
        %axis xy equal tight;
        %daspect([1, 1, 1]);
        c = colorbar;
        xlabel('Eastings (m)');
        ylabel('Northings (m)');
        title('Interpolated Height');
        set(gca, 'Color', 'w');
        set(findobj(gca,'Type','Image'), 'AlphaData', ~isnan(interpolatedC2));
        clim([0,maxColorHeight])
        c.Label.String = 'Height (m)';
        daspect([1,1,1])
    
    figureHandle2 = figure;
        imagesc(xlinspace, ylinspace, interpolatedC2);
        axis xy equal
        %axis xy equal tight;
        %daspect([1, 1, 1]);
        c = colorbar;
        xlabel('Eastings (m)');
        ylabel('Northings (m)');
        title('Interpolated Length');
        set(gca, 'Color', 'w');
        set(findobj(gca,'Type','Image'), 'AlphaData', ~isnan(interpolatedC2));
        clim([min(c2)+1,maxColorLength])
        c.Label.String = 'Length (m)';
        daspect([1,1,1])
end