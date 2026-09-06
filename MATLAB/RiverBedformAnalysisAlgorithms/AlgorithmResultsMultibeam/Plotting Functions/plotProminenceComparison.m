function plotProminenceComparison()
% PLOTPROMINENCECOMPARISON Visualizes dune metric variation across prominence thresholds.
%   PLOTPROMINENCECOMPARISON loads three datasets of extracted dunes using different
%   prominence thresholds (low, center, high). Calculates mean dune length and height
%   for each dataset and compares the variability by computing the percent half range. 
%   The results are shown in histograms.
%
%   PLOTPROMINENCECOMPARISON() plots prominence comparison figures.
%
%   Other Functions Referenced:
%       load(...), readtable(...), histogram(...), exportgraphics(...), tiledlayout(...),
%       nexttile(...), xlabel(...), ylabel(...), figure(...), xlim(...), ylim(...),
%       xticks(...), get(...), set(...), legend(...), gca(...), arrayfun(...),
%       mean(...), pbaspect(...), disp(...)
%
%
%   -- Matthew Free 07/2025 --

%% Get Data
    load("MoRiverMultibeamDataProminence0.0900.mat")
    HighProm = MoRiverData;
    load("MoRiverMultibeamData.mat")
    CenterProm = MoRiverData;
    load("MoRiverMultibeamDataProminence0.0450.mat")
    LowProm = MoRiverData;

    H_HighProm = arrayfun(@(x) mean(x.H), HighProm);
    H_CenterProm = arrayfun(@(x) mean(x.H), CenterProm);
    H_LowProm = arrayfun(@(x) mean(x.H), LowProm);

    L_HighProm = arrayfun(@(x) mean(x.L), HighProm);
    L_CenterProm = arrayfun(@(x) mean(x.L), CenterProm);
    L_LowProm = arrayfun(@(x) mean(x.L), LowProm);

    H_Range = 100*(0.5 .* (H_HighProm - H_LowProm)) ./ H_CenterProm;
    L_Range = 100*(0.5 .* (L_HighProm - L_LowProm)) ./ L_CenterProm;

    figure("Name", "Length Range Histogram");
        histogram(H_Range, "FaceColor",[0.6,0.6,0.6], "BinEdges",[0:20]);
        xlabel("⟨L⟩_{range} (%)")
        ylabel("Count")
        xlim([0,20])
        ylim([0,140])
        set(findall(gcf,'-property','FontName'),'FontSize',12);
        %set(findobj(gcf, 'Type', 'Legend'),'FontSize',11);
        set(gcf, 'Units', 'inches');
        pos = get(gcf, 'Position');
        set(gcf, 'Position', [pos(1), pos(2), 6.5, 6.5*pos(4)/pos(3)]); set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 3.5 3.5*pos(4)/pos(3)]);
        pbaspect([1,1,1])
        box on
        grid
        exportgraphics(gcf, [get(gcf, 'Name') '.png'], 'Resolution', 300);

    figure("Name", "Height Range Histogram");
        histogram(L_Range, "FaceColor",[0.6,0.6,0.6], "BinEdges",[0:20]);
        xlabel("⟨H⟩_{range} (%)")
        ylabel("Count")
        xlim([0,20])
        ylim([0,140])
        set(findall(gcf,'-property','FontName'),'FontSize',12);
        %set(findobj(gcf, 'Type', 'Legend'),'FontSize',11);
        set(gcf, 'Units', 'inches');
        pos = get(gcf, 'Position');
        set(gcf, 'Position', [pos(1), pos(2), 6.5, 6.5*pos(4)/pos(3)]); set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 3.5 3.5*pos(4)/pos(3)]);
        pbaspect([1,1,1])
        box on
        grid
        exportgraphics(gcf, [get(gcf, 'Name') '.png'], 'Resolution', 300);

        disp(mean(L_Range))
        disp(mean(H_Range))
end