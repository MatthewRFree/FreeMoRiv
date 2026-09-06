function plotBradleyAndVenditti(bin, scale, markerSize)
% PLOTBRADLEYANDVENDITTI Takes Length and Height values and plots against flow depth
%   PLOTBRADLEYANDVENDITTI allows for a scatter visualization of how length 
%   and height compare to flow. A fitted line is plotted over.
%
%   PLOTBRADLEYANDVENDITTI(BIN,SCALE,MARKERSIZE) takes in inputs for the
%   scatter point size MARKERSIZE, whether the data should be binned
%   BIN, and SCALE designating linear or log scale. BIN can either be "on" or "off".
%
%   Other Functions Referenced:
%       length(...), load(...), find(...), tiledlayout(...), scatter(...),
%       linspace(...), curveFit(...), semilogy(...), xlim(...), ylim(...),
%       xlabel(...), ylabel(...), legend(...)
%
%
%   -- Matthew Free 07/2025 --

%% Arguments
    arguments
        bin string {mustBeMember(bin, ["on","off"])} = "off"
        scale string {mustBeMember(scale, ["lin", "log"])} = "log"
        markerSize double {mustBeInRange(markerSize, 1, 250)} = 10;
    end
    load("SingleBeamFlowDepthVariables.mat");
    load("FlowDepthTable.mat")

    switch bin
        case "off"
            load("MoRiverMultibeamData.mat")
            for i = 1:length(MoRiverData)
                averageOverallLength(i) = mean(MoRiverData(i).L);
                averageOverallHeight(i) = mean(MoRiverData(i).H);
                %averageOverallDepth(i) = mean(MoRiverData(i).h);
            end
                averageOverallDepth = FlowDepthTable.flowDepthsOnProfiles';
        case "on"
            [~, averageOverallLength, averageOverallHeight, averageOverallDepth, ~, ~, ~, ~] = binData(0.1);
    end

    singleBeamLength = [aprilLength; mayLength; juneLength];
    singleBeamHeight = [aprilHeight; mayHeight; juneHeight];
    singleBeamDepth = [aprilDepth; mayDepth; juneDepth];

%% Plot Data
    figure("Name","Dune Scale vs Flow Depth Length")
        x = linspace(0, 50, 1000);
        y2 = 5.22*x.^0.95;
        y3 = 1.62*x.^0.95;
        y4 = 16.83*x.^0.95;
        [A,B,fitX, fitY, paramFit90] = curveFit(averageOverallDepth, averageOverallLength, 3:0.01:12);
        y5 = paramFit90.a95*fitX.^B;
        y6 = paramFit90.a5*fitX.^B;
        
        fprintf("a1: %f, a2: %f\n", paramFit90.a95, paramFit90.a5)
        fprintf("m: %f, a: %f\n", B, A)
        fprintf("R^{2} was %.2f and pa was %f and pb was %f\n", paramFit90.R2, paramFit90.p(1), paramFit90.p(2))

        % B&V Fit
        semilogy(x, y2, '-k')
        hold on

        % B&V 90%
        semilogy(x, y4, '--k', "HandleVisibility", "off")
        semilogy(x, y3, '--k')

        % Free Fit
        semilogy(fitX, fitY, '-', 'Color', [0.4940 0.1840 0.5560]);

        % Free 90%
        semilogy(fitX, y5,'--', 'Color', [0.4940 0.1840 0.5560], "HandleVisibility", "off")
        semilogy(fitX, y6,'--', 'Color', [0.4940 0.1840 0.5560])

        scatter(averageOverallDepth, averageOverallLength, markerSize, [0.2, 0.2, 0.2], "filled")
        scatter(singleBeamDepth, singleBeamLength, markerSize*2, [0.4, 0.4, 0.4],'x')

        legend("B&V2017 ⟨L⟩=5.22*⟨h⟩^{0.95}", "B&V2017 90% Interval_{}", sprintf("This Study Fit ⟨L⟩=%.2f*⟨h⟩^{%.2f}",A,B), "This Study 90% Interval_{}", "This Study_{}", "Free et al. (2025)_{}", "Location","northwest")
        ylabel("Mean Bedform Length, ⟨L⟩ (m)")
        xlabel("Mean Flow Depth, ⟨h⟩ (m)")
        if scale == "lin"
            xlim([2,13])
            ylim([6,23])
        elseif scale == "log"
            set(gca, 'YScale', 'log')
            set(gca, 'XScale', 'log')
            yticks([6:1:10, 20, 30, 40]);
            ylim([6,40])
            yticklabels(string([6,nan,8,nan,10,20,30,40]))
            xticks([1:10, 20])
            xlim([1,20])
            xticklabels(string(xticks))
            
            ax = gca;
            ax.XMinorTick = 'on';
            ax.YMinorTick = 'on';
            yticksMinor = [6:0.25:10, 12.5:2.5:40];
            xticksMinor = [1:0.25:10, 12.5:2.5:20];
            ax.XAxis.MinorTickValues = xticksMinor;
            ax.YAxis.MinorTickValues = yticksMinor;
        end
        grid
        set(findall(gcf,'-property','FontSize'),'FontSize',12);
        set(findobj(gcf, 'Type', 'Legend'),'FontSize',11);
        set(gcf, 'Units', 'inches');
        pos = get(gcf, 'Position');
        set(gcf, 'Position', [pos(1), pos(2), 6.5, 6.5*pos(4)/pos(3)]); set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 3.5 3.5*pos(4)/pos(3)]);
        pbaspect([5,3,1])
        box on;
        %exportgraphics(gcf, [get(gcf, 'Name') '.png'], 'Resolution', 300);
        
    figure("Name","Dune Scale vs Flow Depth Height")
        y2 = 0.13*x.^0.94;
        y3 = 0.05*x.^0.94;
        y4 = 0.38*x.^0.94;
        [A,B,fitX, fitY, paramFit90] = curveFit(averageOverallDepth, averageOverallHeight, 3:0.01:12);
        y5 = paramFit90.a95*fitX.^B;
        y6 = paramFit90.a5*fitX.^B;

        fprintf("a1: %f, a2: %f\n", paramFit90.a95, paramFit90.a5)
        fprintf("m: %f, a: %f\n", B, A)
        fprintf("R^{2} was %.2f and pa was %f and pb was %f\n", paramFit90.R2, paramFit90.p(1), paramFit90.p(2))

        % B&V Fit
        semilogy(x, y2, '-k')
        hold on

        % B&V 90%
        semilogy(x, y4, '--k', "HandleVisibility", "off")
        semilogy(x, y3, '--k')
        
        % Free Fit
        semilogy(fitX, fitY, '-', 'Color', [0.4940 0.1840 0.5560])

        % Free 90%
        semilogy(fitX, y5,'--', 'Color', [0.4940 0.1840 0.5560], "HandleVisibility", "off")
        semilogy(fitX, y6,'--', 'Color', [0.4940 0.1840 0.5560])

        scatter(averageOverallDepth, averageOverallHeight, markerSize, [0.2, 0.2, 0.2], "filled")
        scatter(singleBeamDepth, singleBeamHeight, markerSize*2, [0.4, 0.4, 0.4],'x')

        legend("B&V2017 ⟨H⟩=0.13*⟨h⟩^{0.94}", "B&V2017 90% Interval_{}", sprintf("This Study Fit ⟨H⟩=%.2f*⟨h⟩^{%.2f}",A,B), "This Study 90% Interval_{}", "This Study_{}", "Free et al. (2025)_{}", "Location","northwest")
        xlabel("Mean Flow Depth, ⟨h⟩ (m)")
        ylabel("Mean Bedform Height, ⟨H⟩ (m)")
        if scale == "lin"
            xlim([2,13])
            ylim([0,1])
        elseif scale == "log"
            set(gca, 'YScale', 'log')
            set(gca, 'XScale', 'log')
            yticks([0.1:0.1:1, 2,3]);
            ylim([0.1,3])
            yticklabels(string([0.1,0.2,nan,0.4,nan,0.6,nan,0.8,nan,1,2,3]))
            xticks([1:10, 20])
            xlim([1,20])
            xticklabels(string(xticks))
            
            ax = gca;
            ax.XMinorTick = 'on';
            ax.YMinorTick = 'on';
            yticksMinor = [0.1:0.025:1, 1.25:0.25:3];
            xticksMinor = [1:0.25:10, 12.5:2.5:20];
            ax.XAxis.MinorTickValues = xticksMinor;
            ax.YAxis.MinorTickValues = yticksMinor;
        end
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