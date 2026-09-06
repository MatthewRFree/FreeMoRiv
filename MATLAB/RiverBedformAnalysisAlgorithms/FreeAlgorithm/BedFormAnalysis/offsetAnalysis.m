function offsetAnalysis(data, month1, month2, xStart, xLength)
% OFFSETANALYSIS Compare and visualize dune offsets between two months.
%   OFFSETANALYSIS creates various plots to see how the offset from the
%   sailing line may affect the data.
%
%   OFFSETANALYSIS(DATA,MONTH1,MONTH2,XSTART,XLENGTH) retrieves and
%   compares offset data DATA for left, center, and right dune sections between
%   MONTH1 and MONTH2 within the specified river mile range starting at
%   XSTART for a length of XLENGTH. It produces plots and histograms to
%   help visualize spatial and statistical differences in offset from sailing line.
%
%   Other Functions Referenced:
%       getData(...), min(...), max(...), figure(...), subplot(...),
%       title(...), plot(...), legend(...), daspect(...), xlabel(...),
%       ylabel(...), histogram(...), find(...)
%       
%
% -- Matthew Free 06/2024 --

%% Arguments
    arguments
        data struct
        month1 string
        month2 string
        xStart double
        xLength double
    end

%% Get Data
    % Various offset analysis methods
        [xCenter1, offsetCenter1, xCenter2, offsetCenter2] = getData(data, month1, month2, "Center", 'o', xStart, xLength);
        [xRight1, offsetRight1, xRight2, offsetRight2] = getData(data, month1, month2, "Right", 'o', xStart, xLength);
        [xLeft1, offsetLeft1, xLeft2, offsetLeft2] = getData(data, month1, month2, "Left", 'o', xStart, xLength);
    
    % Gets information for plot aspect ratio
        minY = min((offsetCenter1 + offsetCenter2)/2) - 1;
        maxY = max((offsetCenter1 + offsetCenter2)/2) + 1;
        ratio = 400;
        Ratio = ratio/8;

%% PLOT OFFSET
    figure("Name", "Plot Offset")
    subplot(3, 2, 1)
        title("Center")
        plot(xCenter1, offsetCenter1, xCenter2, offsetCenter2);
        legend(month1, month2);
        axis equal
        daspect([(maxY-minY)/Ratio, maxY - minY, 1]);
        grid on
    
    subplot(3, 2, 3)
        title("Right")
        plot(xRight1, offsetRight1, xRight2, offsetRight2);
        legend(month1, month2);
        axis equal
        daspect([(maxY-minY)/Ratio, maxY - minY, 1]);
        ylabel("Offset (ft)");
        grid on
    
    subplot(3, 2, 5)
        title("Left")
        plot(xLeft1, offsetLeft1, xLeft2, offsetLeft2);
        legend(month1, month2);
        axis equal
        daspect([(maxY-minY)/Ratio, maxY - minY, 1]);
        xlabel("River Mile");
        grid on

%% HISTOGRAM COMPARISON
    binWidth = 2;
    
    % Compares one month to the next by the difference between offsets
        oCenter = offsetCenter2 - offsetCenter1;
        oLeft = offsetLeft2 - offsetLeft1;
        oRight = offsetRight2 - offsetRight1;
    
    subplot(3, 2, 2);
        histogram(oCenter, "FaceAlpha", 0.7, "FaceColor", [0 0.4470 0.7410], "BinWidth", binWidth);
        legend("Center")
    subplot(3, 2, 4);
        histogram(oLeft, "FaceAlpha", 0.7, "FaceColor", [0.4660 0.6740 0.1880], "BinWidth", binWidth);
        legend("Left")
    subplot(3, 2, 6);
        histogram(oRight, "FaceAlpha", 0.7, "FaceColor", [0.8500 0.3250 0.0980], "BinWidth", binWidth);
        legend('Right');
        xlabel("Difference in Offset (ft)")

%% PLOT OF BEDFORM WITHIN TOLERANCE
        tolerance = 3;
    
        ci = find(abs(oCenter) < tolerance);
        li = find(abs(oLeft) < tolerance);
        ri = find(abs(oRight) < tolerance);
    
        [xc1, yc1, xc2, yc2] = getData(data, month1, month2, "Center", 'x', xStart, xLength);
    
    figure("Name","Plots at Low Offset")
    
        minY = min(min(yc2), min(yc2)) - 1;
        maxY = max(max(yc2), max(yc2)) + 1;
        plot(xc1(ci), yc1(ci), '.');
        hold on;
        plot(xc2(ci), yc2(ci), '.');
        hold off;
        legend(month1, month2);
        axis equal
        daspect([(maxY-minY)/400, maxY - minY, 1]);
        title(sprintf("%s vs %s", month1, month2));
        xlabel("River Mile");
        ylabel("Height (ft)");
        grid on;
end

