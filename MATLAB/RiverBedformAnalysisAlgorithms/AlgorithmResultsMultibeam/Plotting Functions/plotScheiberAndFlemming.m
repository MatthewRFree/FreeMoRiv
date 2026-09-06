function plotScheiberAndFlemming(bin, scale, markerSize)
% PLOTSCHIBERANDFLEMMING Plots Length vs Height values
%   PLOTSCHIBERANDFLEMMING allows for a scatter visualization of how length 
%   and height compare. A fitted line is plotted over.
%
%   PLOTSCHIBERANDFLEMMING(BIN,SCALE,MARKERSIZE) takes in inputs for the
%   scatter point size MARKERSIZE, whether the data should be binned
%   BIN, and SCALE designating linear or log scale. BIN can either be "on" or "off".
%
%   Other Functions Referenced:
%       length(...), load(...), find(...), tiledlayout(...), scatter(...),
%       linspace(...), semilogy(...), xlim(...), ylim(...), xlabel(...), 
%       ylabel(...), legend(...)
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

    switch bin
        case "off"
            load("MoRiverMultibeamData.mat")
            for i = 1:length(MoRiverData)
                averageOverallLength(i) = mean(MoRiverData(i).L);
                averageOverallHeight(i) = mean(MoRiverData(i).H);
                color(i) = mean(MoRiverData(i).h);
            end

        case "on"
            [~, averageOverallLength, averageOverallHeight, ~, ~, ~, ~, ~] = binData(0.1);
    end

%% Plot Data
    figure("Name","Dune Height vs Dune Length")
        x = linspace(0.0001, 1000, 10000);
        y1 = 0.16*x.^0.84;

        y3 = 0.049*x.^0.84;
        y4 = 0.021*x.^0.84;
        y5 = 0.112*x.^0.84;
        y6 = 0.0513*x.^0.7744;

        % Flemming
        plot(x, y1, '-k')
        hold on;

        % % Scheiber Median
        % plot(x, y3, '-b')
        % 
        % % Scheiber 5/95 %
        % plot(x, y4, '--b')
        % plot(x, y5, '--b', "HandleVisibility","off")

        % B&V 2017
        plot(x,y6,'-b')
        
        % Dummy point for legend
        plot(nan, nan, 'ko', 'MarkerFaceColor', 'k');

        % Data
        scatter(averageOverallLength, averageOverallHeight, markerSize, color, "filled", "HandleVisibility","off")

        colormap("turbo")
        cb = colorbar;
        cb.Label.String ='Mean Flow Depth, ⟨h⟩ (m)';

        %legend("Flemming (1988) H_{max}=0.16*L^{0.84}", "Scheiber et al. (2024) Median_{}", "Scheiber et al. (2024) 90% Interval_{}", "This Study", "Location","northwest");
        legend("Flemming (1988) H_{max}=0.16*L^{0.84}", "B&V2017 ⟨H⟩=0.0513*⟨L⟩^{0.7744}", "This Study", "Location","northwest");

        xlabel("Mean Bedform Length, ⟨L⟩ (m)")
        ylabel("Mean Bedform Height, ⟨H⟩ (m)")
        if scale == "lin"
            xlim([2.5, 25])
            ylim([0.05, 1])
        elseif scale == "log"
            xlim([8, 16])
            ylim([0.1, 2])
            set(gca, 'YScale', 'log')
            set(gca, 'XScale', 'log')
            yticks([0.1:0.1:1, 2]);
            xticks(6:18)
            xticklabels(string(xticks))
            yticklabels(string([0.1,0.2,0.3,0.4,nan,0.6,nan,0.8,nan,1,2]))
            
            ax = gca;
            ax.XMinorTick = 'on';
            ax.YMinorTick = 'on';
            yticksMinor = [0.1:0.025:1, 1.25:0.25:2];
            xticksMinor = 6:0.25:18;
            ax.XAxis.MinorTickValues = xticksMinor;
            ax.YAxis.MinorTickValues = yticksMinor;
        end
        grid on

        set(findall(gcf,'-property','FontName'),'FontSize',12);
        set(findobj(gcf, 'Type', 'Legend'),'FontSize',11);
        set(gcf, 'Units', 'inches');
        pos = get(gcf, 'Position');
        set(gcf, 'Position', [pos(1), pos(2), 6.5, 6.5*pos(4)/pos(3)]); set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 3.5 3.5*pos(4)/pos(3)]);
        pbaspect([3,2,1])
        box on
        %exportgraphics(gcf, [get(gcf, 'Name') '.png'], 'Resolution', 300);
end