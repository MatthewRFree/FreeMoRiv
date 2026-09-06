function plotDuneHeightLength(month1, X, Y, peakIndices, troughIndices, primaryHeight, secondaryHeight, primaryLength, secondaryLength)
% PLOTDUNEHEIGHTLENGTH Plots the dune heights and lengths
%   PLOTDUNEHEIGHTLENGTH creates a histogram for the primary heights and
%   lengths as well as the secondary heights and lengths. Creates a plot of
%   the bedform with the primary peaks plotted as red dots and the primary 
%   troughs plotted as blue dots. Prints the average primary and secondary
%   dune heights and lengths.
%
%   PLOTDUNEHEIGHTLENGTH(MONTH1,X,Y,PEAKINDICES,TROUGHINDICES,PRIMARYHEIGHT,
%                        SECONDARYHEIGHT,PRIMARYLENGTH,SECONDARYLENGTH)
%   takes in the first month MONTH1 as a string, vectors X and Y as the
%   bedform data, the indice locations of the peaks and troughs as
%   PEAKINDICES and TROUGHINDICES, and four vectors containing the heights
%   and lengths of the dunes as PRIMARYHEIGHT, SECONDARYHEIGHT,
%   PRIMARYLENGTH, and SECONDARYLENGTH.
%
%   Other Functions Referenced:
%       min(...), max(...), figure(...), plot(...), hold(), axis(),
%       daspect(...), xlabel(...), ylabel(...), title(...), subplot(...),
%       histogram(...), legend(...), fprintf(...)
%
%
%   -- Matthew Free 07/2024 --

%% Arguments
    arguments
        month1 (1, 1) string {mustBeMember(month1, ["January", "February", "March","April", "May", "June", ...
                                            "July", "August", "September", "October", "November", "December"])}
        X double
        Y double
        peakIndices double
        troughIndices double
        primaryHeight double
        secondaryHeight double
        primaryLength double
        secondaryLength double
    end

%% Prep Data
    % calculate y min and y max with an offset of 1 for plot aspect ratio
        minY = min(min(Y), min(Y)) - 1;
        maxY = max(max(Y), max(Y)) + 1;

%% Plot Bedform with Primary Peaks and Troughs
    figure("Name",'Peaks and Troughs')
        plot(X, Y, 'Color',[0.8, 0.8, 0.8]);
        hold on;
        plot(X(peakIndices), Y(peakIndices), 'or');
        plot(X(troughIndices), Y(troughIndices), 'ob');
        plot(X, Y, "-k");
        axis equal;
        daspect([(maxY-minY)/400, maxY - minY, 1]);
        xlabel("River Mile (mi)");
        ylabel("Elevation (ft)");
        title(sprintf("An Analysis of %s", month1));
        hold off;

%% Histogram of Major and Minor dune Heights and Lengths
    figure("Name","Dune Lengths")
        subplot(2, 2, 1);
        histogram(primaryLength, "FaceAlpha", 0.7, "FaceColor", [0 0.4470 0.7410], "BinWidth", nanmean(primaryLength)/10);
        legend("Primary Length")
        xlabel("Dune Length (meters)")
        subplot(2, 2, 2);
        histogram(secondaryLength, "FaceAlpha", 0.7, "FaceColor", [0.4660 0.6740 0.1880], "BinWidth", nanmean(secondaryLength)/5);
        legend("Secondary Length")
        xlabel("Dune Length (meters)")
        subplot(2, 2, 3);
        histogram(primaryHeight, "FaceAlpha", 0.7, "FaceColor", [0.8500 0.3250 0.0980], "BinWidth", nanmean(primaryHeight)/10);
        legend("Primary Height")
        xlabel("Dune Height (meters)")
        subplot(2, 2, 4);
        histogram(secondaryHeight, "FaceAlpha", 0.7, "FaceColor", [1, 0.431, 0.612], "BinWidth", nanmean(secondaryHeight));
        legend("Secondary Height")
        xlabel("Dune Height (meters)")

%% Print Data 
    % Print Averages
        fprintf("The average primary dune length was: %.3f (meters).\n", mean(primaryLength));
        fprintf("The average secondary dune length was: %.3f (meters).\n", mean(secondaryLength));
        fprintf("The average primary dune height was: %.3f (meters).\n", mean(primaryHeight));
        fprintf("The average secondary dune height was: %.3f (meters).\n", mean(secondaryHeight));
end

