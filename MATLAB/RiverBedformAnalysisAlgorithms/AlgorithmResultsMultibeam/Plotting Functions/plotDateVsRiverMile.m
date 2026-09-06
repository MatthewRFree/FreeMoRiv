function plotDateVsRiverMile(byLoc, markerSize)
% PLOTDATEVSRIVERMILE plots date and rivermile for each survey
%   PLOTDATEVSRIVERMILE plots a tiled layout of three plots containing a
%   hydrograph of the discharge in (cfs) as well as date vs rivermile
%   colored by the scale of dune height and length at that point.
%
%   PLOTDATEVSRIVERMILE(BYLOC,MARKERSIZE) plots with the desired point size
%   MARKERSIZE. default size of 20 is set. Plots BYLOC by location if "on"
%   and the whole set if "off".
%
%   Other Functions Referenced:
%       load(...), arrayfun(...), mean(...), figure(...), tiledlayout(...),
%       plot(...), title(...), xlim(...), ylim(...), xlabel(...),
%       ylabel(...), scatter(...)
%
%
% -- Matthew Free 06/2025 --

%% Arguments
    arguments
        byLoc string {mustBeMember(byLoc, ["on", "off"])} = "off"
        markerSize = 10;
    end

%% Get Data
    load("MoRiverMultibeamData.mat")
    
    if byLoc == "on"
        gageLocs = unique([MoRiverData.GageLocation]);
        loop = length(gageLocs);

        for i = 1:loop
            load(sprintf("%s%s", "..\FreeAlgorithm\MultiBeamDataLoading\SupplementalRiverData\", gageLocs(i)))
            mask = find([MoRiverData.GageLocation] == gageLocs(i));
        
                D = [MoRiverData(mask).Date];
                RM = [MoRiverData(mask).RiverMileStart];
                H = arrayfun(@(x) mean(x.H), MoRiverData(mask));
                L = arrayfun(@(x) mean(x.L), MoRiverData(mask));
            
            %% Plot Data
            if length(D) > 10
                figure("Name","Gage Height vs Dune Scales")
                    tiledlayout(3,1);
                
                    nexttile
                    plot(GageData,"Dates_TH","Q");
                    title(gageLocs(i))
                    xlim([datetime("2020-09-01"), datetime("2025-01-01")])
                    xlabel("Date")
                    ylabel("Q (cms)")
                    grid
                
                    nexttile
                    scatter(D, RM, markerSize, H, 'filled');
                    colorbar;
                    clim([prctile(arrayfun(@(x) mean(x.H), MoRiverData),2),prctile(arrayfun(@(x) mean(x.H), MoRiverData),98)])
                    title('H Values');
                    ylabel("River Mile (mi)")
                    xlim([datetime("2020-09-01"), datetime("2025-01-01")])
                    ylim([min(RM) - 5, max(RM) + 5])
                    grid
                
                    nexttile
                    scatter(D, RM, markerSize, L, 'filled');
                    colorbar;
                    clim([prctile(arrayfun(@(x) mean(x.L), MoRiverData),2),prctile(arrayfun(@(x) mean(x.L), MoRiverData),98)])
                    title('L Values');
                    xlim([datetime("2020-09-01"), datetime("2025-01-01")])
                    ylim([min(RM) - 5, max(RM) + 5])
                    xlabel("Date")
                    grid
                
                    colormap("turbo")
    
                figure
                    scatter(GageData{D,"Q"}, L, 36, RM, 'filled')
                    colorbar
                    colormap("turbo")
            end
        end
    elseif byLoc == "off"
        D = [MoRiverData.Date];
        RM = [MoRiverData.RiverMileStart];
        L = arrayfun(@(x) mean(x.L), MoRiverData);
        H = arrayfun(@(x) mean(x.H), MoRiverData);
        fprintf("%f\t%f\t", min(L), min(H))
        fprintf("%f\t%f\t", max(L), max(H))
            
    %% Plot Data
        figure("Name","Date vs RKM")
            scatter(D, RM*1.60934, markerSize, [0.2, 0.2, 0.2],'filled');
            xlim([datetime("2021-01-01"), datetime("2025-07-01")])
            ylim([0, 600])
            xlabel("Date")
            ylabel("River KM")

            yticks(0:50:600);
            xticks(datetime("2021-01-01"):calmonths(12):datetime("2025-01-01"));
            xticklabels(["2021", "2022", "2023", "2024", "2025"]);
            yticklabels(string(yticks))

            ax = gca;
            ax.XMinorTick = 'on';
            ax.YMinorTick = 'on';
            yticksMinor = 25:12.5:600;
            xticksMinor = datetime("2021-01-01"):calmonths(3):datetime("2025-07-01");
            ax.XAxis.MinorTickValues = xticksMinor;
            ax.YAxis.MinorTickValues = yticksMinor;

            ax.XMinorGrid = 'on';
            ax.YMinorGrid = 'on';
            
            %ax.MinorGridLineStyle = ':';
            %ax.MinorGridAlpha = 0.1;
            legend("This Study", "Location","northwest")
            grid on
            pbaspect([3,2,1])
            set(findall(gcf,'-property','FontSize'),'FontSize',12);
            set(gcf, 'Units', 'inches');
            pos = get(gcf, 'Position');
            set(gcf, 'Position', [pos(1), pos(2), 6.5, 6.5*pos(4)/pos(3)]); set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 3.5 3.5*pos(4)/pos(3)]);
            box on
            %exportgraphics(gcf, [get(gcf, 'Name') '.png'], 'Resolution', 300);
    end
end