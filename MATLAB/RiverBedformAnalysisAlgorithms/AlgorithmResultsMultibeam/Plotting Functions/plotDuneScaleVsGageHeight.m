function plotDuneScaleVsGageHeight(color, markerSize)
% PLOTDUNESCALEVSFLOW Takes Length and Height values and plots against gage height
%   PLOTDUNESCALEVSFLOW allows for a scatter visulaization of how length 
%   and height compare to gage height. A least squares line is plotted over 
%   to show the trend.
%
%   PLOTDUNESCALEVSFLOW(COLOR,MARKERSIZE) takes in inputs for the
%   scatter point size MARKERSIZE and scatter point color COLOR.
%
%   Other Functions Referenced:
%       figure(...), subplot(...), scatter(...), xlabel(...), ylabel(...),
%       lsline(), xlim(...), ylim(...), max(...), min(...), mean(...),
%       length(...), load(...)
%
%
%   -- Matthew Free 05/2025 --

%% Arguments
    arguments
        color = [0 0.4470 0.7410]
        markerSize double {mustBeInRange(markerSize, 1, 250)} = 25
    end

%% Get Data
    load("MoRiverMultibeamData.mat")

    for i = 1:length(MoRiverData)
        gageHeight(i) = MoRiverData(i).GageHeight;
        L1(i) = mean(MoRiverData(i).L(1:length(MoRiverData(i).ProfileL{1})));
        H1(i) = mean(MoRiverData(i).H(1:length(MoRiverData(i).ProfileL{1})));
        L2(i) = mean(MoRiverData(i).L);
        H2(i) = mean(MoRiverData(i).H);
    end

%% Plot Data
    avgQ = mean(gageHeight);
    numBins = 25;
    figure("Name","Dune Scale vs Gage Height");
    subplot(2, 2, 1)
        scatter(gageHeight, L1, markerSize, color, '.')
        ylabel("Average Sailing Line Dune Length (m)")
        xlabel("Gage Height (m)")
        lsline
        xlim([min(gageHeight) - avgQ/3, max(gageHeight) + avgQ/3])
        ylim([0, max(L1) + mean(L1)/2])
        R = corrcoef(gageHeight, L1);
        RSquared = R(1,2)^2;
        text(0,0, sprintf("%s%s"," R^2 = ", num2str(RSquared)), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');

    subplot(2, 2, 2)
        scatter(gageHeight, H1, markerSize, color, '.')
        ylabel("Average Sailing Line Dune Height (m)")
        xlabel("Gage Height (m)")
        lsline
        xlim([min(gageHeight) - avgQ/3, max(gageHeight) + avgQ/3])
        ylim([0, max(H1) + mean(H1)/2])
        R = corrcoef(gageHeight, H1);
        RSquared = R(1,2)^2;
        text(0,0, sprintf("%s%s"," R^2 = ", num2str(RSquared)), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');

    subplot(2, 2, 3)
        scatter(gageHeight, L2, markerSize, color, '.')
        ylabel("Average Overall Dune Length (m)")
        xlabel("Gage Height (m)")
        lsline
        xlim([min(gageHeight) - avgQ/3, max(gageHeight) + avgQ/3])
        ylim([0, max(L2) + mean(L2)/2])
        R = corrcoef(gageHeight, L2);
        RSquared = R(1,2)^2;
        text(0,0, sprintf("%s%s"," R^2 = ", num2str(RSquared)), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');

    subplot(2, 2, 4)
        scatter(gageHeight, H2, markerSize, color, '.')
        ylabel("Average Overall Dune Height (m)")
        xlabel("Gage Height (m)")
        lsline
        xlim([min(gageHeight) - avgQ/3, max(gageHeight) + avgQ/3])
        ylim([0, max(H2) + mean(H2)/2])
        R = corrcoef(gageHeight, H2);
        RSquared = R(1,2)^2;
        text(0,0, sprintf("%s%s"," R^2 = ", num2str(RSquared)), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');

figure("Name","Residual Density Plot");
    subplot(2, 2, 1)
        lineData = fitlm(gageHeight, L1);
        residuals = lineData.Residuals.Raw;
        histogram(residuals, 'Normalization', 'pdf', 'BinWidth',(max(residuals)-min(residuals))/numBins);
        xlabel('Residual (y - y_{fit})');
        ylabel('Probability Density');
        title('Sailing Line Length R Density');

    subplot(2, 2, 2)
        lineData = fitlm(gageHeight, H1);
        residuals = lineData.Residuals.Raw;
        histogram(residuals, 'Normalization', 'pdf', 'BinWidth',(max(residuals)-min(residuals))/numBins);
        xlabel('Residual (y - y_{fit})');
        ylabel('Probability Density');
        title('Sailing Line Height R Density');

    subplot(2, 2, 3)
        lineData = fitlm(gageHeight, L2);
        residuals = lineData.Residuals.Raw;
        histogram(residuals, 'Normalization', 'pdf', 'BinWidth',(max(residuals)-min(residuals))/numBins);
        xlabel('Residual (y - y_{fit})');
        ylabel('Probability Density');
        title('Overall Length R Density');

    subplot(2, 2, 4)
        lineData = fitlm(gageHeight, H2);
        residuals = lineData.Residuals.Raw;
        histogram(residuals, 'Normalization', 'pdf', 'BinWidth',(max(residuals)-min(residuals))/numBins);
        xlabel('Residual (y - y_{fit})');
        ylabel('Probability Density');
        title('Overall Height R Density');
end