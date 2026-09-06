function plotSteepnessVsFlowDepth()
% PLOTSTEEPNESSVSFLOWDEPTH Visualizes dune steepness as a function of flow depth.
%   PLOTSTEEPNESSVSFLOWDEPTH creates a log-log scatter plot of dune steepness (H/L)
%   versus mean flow depth (h) using multibeam and singlebeam datasets. A power-law
%   fit is applied to the multibeam data, and the curve is plotted with 90% confidence
%   bounds. Singlebeam points are plotted for visual reference.
%
%   PLOTSTEEPNESSVSFLOWDEPTH() generates and exports the figure.
%
%   Other Functions Referenced:
%       semilogy(...), scatter(...), curveFit(...), mean(...), legend(...),
%       xlabel(...), ylabel(...), xlim(...), ylim(...), xticks(...), yticks(...),
%       xticklabels(...), yticklabels(...), set(...), exportgraphics(...),
%       load(...), fprintf(...), get(...), pbaspect(...)
%
%
%   -- Matthew Free 08/2025 --

%% Get Data
    markerSize = 10;
    load("SingleBeamFlowDepthVariables.mat");
    load("MoRiverMultibeamData.mat")
    load("FlowDepthTable.mat")

        for i = 1:length(MoRiverData)
            averageOverallLength = MoRiverData(i).L;
            averageOverallHeight = MoRiverData(i).H;
            averageOverallSteepness(i) = mean(averageOverallHeight./averageOverallLength);
            %averageOverallDepth(i) = mean(MoRiverData(i).h);
        end
            averageOverallDepth = FlowDepthTable.flowDepthsOnProfiles';

    singleBeamLength = [aprilLength; mayLength; juneLength];
    singleBeamHeight = [aprilHeight; mayHeight; juneHeight];
    singleBeamDepth = [aprilDepth; mayDepth; juneDepth];

%% Plot
    figure("Name","Steepness Vs FlowDepth")
        [A,B,fitX, fitY, paramFit90] = curveFit(averageOverallDepth, averageOverallSteepness, 3:0.01:12);
        y5 = paramFit90.a95*fitX.^B;
        y6 = paramFit90.a5*fitX.^B;
        
        fprintf("a1: %f, a2: %f\n", paramFit90.a95, paramFit90.a5)
        fprintf("m: %f, a: %f\n", B, A)
        fprintf("R^{2} was %.2f and pa was %f and pb was %f\n", paramFit90.R2, paramFit90.p(1), paramFit90.p(2))

        % Free Fit
        semilogy(fitX, fitY, '-', 'Color', [0.4940 0.1840 0.5560]);
        hold on

        % Free 90%
        semilogy(fitX, y5,'--', 'Color', [0.4940 0.1840 0.5560], "HandleVisibility", "off")
        semilogy(fitX, y6,'--', 'Color', [0.4940 0.1840 0.5560])

        % Data
        scatter(averageOverallDepth, averageOverallSteepness, markerSize, [0.2, 0.2, 0.2], "filled")
        scatter(singleBeamDepth, singleBeamHeight./singleBeamLength, markerSize*2, [0.4, 0.4, 0.4],'x')

        legend(sprintf("This Study Fit ⟨H/L⟩=%.3f*⟨h⟩^{%.2f}",A,B), "This Study 90% Interval_{}", "This Study_{}", "Free et al. (2025)_{}", "Location","northwest")

        xlabel("Mean Flow Depth, ⟨h⟩ (m)")
        ylabel("Mean Bedform Steepness, ⟨H/L⟩")
        set(gca, 'YScale', 'log')
        set(gca, 'XScale', 'log')
        ylim([0.01, 0.2])
        yticks([0.01:0.01:0.1,0.2])
        yticklabels(string([0.01,0.02,nan,0.04,nan,0.06,nan,0.08,nan,0.1,0.2]))

        xticks([1:10, 20])
        xlim([1,20])
        xticklabels(string(xticks))

        ax = gca;
        ax.XMinorTick = 'on';
        ax.YMinorTick = 'on';
        yticksMinor = [0.01:0.0025:0.1, 0.125:0.025:0.2];
        xticksMinor = [1:0.25:10, 12.5:2.5:20];
        ax.XAxis.MinorTickValues = xticksMinor;
        ax.YAxis.MinorTickValues = yticksMinor;

        grid
        set(findall(gcf,'-property','FontSize'),'FontSize',12);
        set(findobj(gcf, 'Type', 'Legend'),'FontSize',11);
        set(gcf, 'Units', 'inches');
        pos = get(gcf, 'Position');
        set(gcf, 'Position', [pos(1), pos(2), 6.5, 6.5*pos(4)/pos(3)]); set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 3.5 3.5*pos(4)/pos(3)]);
        pbaspect([5,3,1])
        box on;
        %exportgraphics(gcf, [get(gcf, 'Name') '.png'], 'Resolution', 300);
end