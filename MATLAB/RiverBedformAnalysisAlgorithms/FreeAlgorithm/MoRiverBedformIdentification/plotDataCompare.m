function plotDataCompare(x1, y1, x2, y2, units, ratio)
% PLOTDATACOMPARE Plots two separate months over each other to compare
%   PLOTDATACOMPARE Plots two months with specified units on top of each
%   other to do a visual comparison of the bedform
%
%   PLOTDATACOMPARE(X1,Y1,X2,Y2) plots the vectors X1 and Y1 vs. X2 and Y2
%
%   PLOTDATACOMPARE(...,UNITS) plots the data converting to the specified
%   units UNITS. UNITS is a string that can be 'metric' or 'imperial'. The
%   default UNITS are 'imperial'. Each specified units also uses an optimal
%   ratio viewing value.
%
%   PLOTDATACOMPARE(...,UNITS,RATIO) plots the data converting to the
%   specified units UNITS and overriding the default scaler value for
%   RATIO.
%
%   Other Functions Referenced:
%       min(...), max(...), figure(...), plot(...), legend(...), axis(),
%       daspect(...), title(...), xlabel(...), ylabel(...), grid()
%
%
%   -- Matthew Free 07/2024 --

%% Arguments
    arguments
        x1 double
        y1 double
        x2 double
        y2 double
        units (1, 1) string {mustBeMember(units, ["imperial", "metric", "none"])} = 'imperial'
        ratio (1, 1) double {mustBeInRange(ratio, 0, 1000)} = 1
    end
%% Prep Data
    % calculate y min and y max with an offset of 1
        minY = min(min(y1), min(y1)) - 1;
        maxY = max(max(y1), max(y1)) + 1;
    
    % unit conversion
        switch units
            case 'metric'
                x1 = x1 * 1609.3;
                x2 = x2 * 1609.3;
                y1 = y1 * 0.305;
                y2 = y2 * 0.305;
                x = "River Mile (meters)";
                y = "Height (meters)";
                ratio = 2;
            case 'imperial'
                x1 = x1 * 5280;
                x2 = x2 * 5280;
                x = "River Mile (ft)";
                y = "Height (ft)";
                ratio = 400;
            case 'none'
                x = "River Mile (mi)";
                y = "Height (ft)";
            otherwise
                x = "River Mile (mi)";
                y = "Height (ft)";
        end
        
%% Plot Data
    figure("Name","Month Comparison");
        plot(x1, y1, x2, y2);
        %legend(month1, month2);
        axis equal
        daspect([(maxY-minY)/ratio, maxY - minY, 1]);
        %title(sprintf("%s vs %s", month1, month2));
        xlabel(x);
        ylabel(y);
        grid on;
end