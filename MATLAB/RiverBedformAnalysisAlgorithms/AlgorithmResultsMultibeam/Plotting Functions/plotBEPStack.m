function plotBEPStack()
% PLOTBEPSTACK Visualizes bathymetric data and dune profiles for selected BEPs.
%   PLOTBEPSTACK loads multibeam survey data, processes bathymetry,
%   and generates multiple figures showing dune peaks and profiles.
%
%   PLOTBEPSTACK() plots the BEPSTACK figures.
%
%   Other Functions Referenced:
%       load(...), readtable(...), rmmissing(...), cBathym(...), getNNxyz(...),
%       getBath(...), getSmoothBath(...), getDiffElev(...), showBathdiffContf(...),
%       showBathContf(...), scatter(...), plot(...), legend(...), xlim(...), ylim(...),
%       xlabel(...), ylabel(...), colorbar(...), tiledlayout(...), nexttile(...),
%       set(...), get(...), box(...), figure(...), xticks(...), yticks(...),
%       xticklabels(...), yticklabels(...), exportgraphics(...)
%
%
%   -- Matthew Free 07/2025 --

%% Get Data
    load("MoRiverMultibeamData.mat")
    survey = MoRiverData(229);
    filename = survey.Filename + ".csv";

    BEP1 = 9;
    BEP2 = 14;

    T = readtable(filename);
    T = rmmissing(T);

    X = T.X.*0.3048006096;
    Y = T.Y.*0.3048006096;
    Z = T.Z.*0.3048006096;

    xBounds = [587400, 587600];
    yBounds = [4270450, 4270650];

        surveyLength = abs(survey.ProfileRiverMile{1,1}(end)-survey.ProfileRiverMile{1,1}(1));

        cBath = cBathym(X, Y, -Z);
        cBath = getNNxyz(cBath,0);

        c_grid      = 1.1;
        c_search    = sqrt(2);

        gridres     = c_grid*cBath.meanNNxyz; 
        Method = [];
        SearchRad   = c_search*gridres;

        cBath = getBath(cBath,cBath.xyz_ptCl,gridres,Method,SearchRad);

        duneEastingPeaks = cell2mat(survey.ProfileEastingPeak(:));
        duneNorthingPeaks = cell2mat(survey.ProfileNorthingPeak(:));
        duneEastingTroughs = cell2mat(survey.ProfileEastingTrough(:));
        duneNorthingTroughs = cell2mat(survey.ProfileNorthingTrough(:));

        % Peaks on Difference
    figure("Name","Dune Peak Raster");
        tiledlayout(1,1)
            nexttile
            [cBath,~] = getSmoothBath(cBath,ceil(mean(survey.L))*2);
            [cBath,~] = getDiffElev(cBath);
            showBathdiffContf(cBath);
            hold on;
            scatter(duneEastingPeaks, duneNorthingPeaks, 18, 'w', 'filled', 'MarkerFaceAlpha', 0.9, "HandleVisibility","off");
            scatter(duneEastingPeaks, duneNorthingPeaks, 12, 'k', 'filled', 'MarkerFaceAlpha', 0.8);

            xlim(xBounds)
            ylim(yBounds)
            xlabel("Easting (m)")
            ylabel("Northing (m)")
            c = colorbar("Location", "southoutside");
            c.Label.String = '\Deltaz (m)';
            legend("Bedform Peaks", "Location","northwest")

            grid on
            set(findall(gcf,'-property','FontSize'),'FontSize',12);
            set(findobj(gcf, 'Type', 'Legend'),'FontSize',11);
            set(gcf, 'Units', 'inches');
            pos = get(gcf, 'Position');
            set(gcf, 'Position', [pos(1), pos(2), 7.5, 7.5*pos(4)/pos(3)]); set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 3.5 3.5*pos(4)/pos(3)]);
            pbaspect([1,1,1])
            box on;
            %exportgraphics(gcf, [get(gcf, 'Name') '.png'], 'Resolution', 300);

    figure("Name","Profile Line Raster");
        tiledlayout(1,1)
            nexttile

            xMask = X >= xBounds(1) & X <= xBounds(2);
            yMask = Y >= yBounds(1) & Y <= yBounds(2);
            areaOfInterestMask = xMask & yMask;
            Xsub = X(areaOfInterestMask);
            Ysub = Y(areaOfInterestMask);
            Zsub = Z(areaOfInterestMask);
            cBathClipped = cBathym(Xsub, Ysub, Zsub);
            cBathClipped = getNNxyz(cBathClipped,0);

            c_grid      = 1.1;
            c_search    = sqrt(2);

            gridres     = c_grid*cBathClipped.meanNNxyz; 
            Method = [];
            SearchRad   = c_search*gridres;

            cBathClipped = getBath(cBathClipped,cBathClipped.xyz_ptCl,gridres,Method,SearchRad);

            showBathContf(cBathClipped)
            clim([prctile(Zsub, 5), prctile(Zsub, 97.5)])
            hold on;
            xlabel("Easting (m)")
            ylabel("Northing (m)")
            c = colorbar("Location", "southoutside");
            c.Label.String = 'h (m)';

            for i = 1:length(survey.ProfileEastingPeak)
                %plot(survey.ProfileEastingPeak{i}, survey.ProfileNorthingPeak{i}, "-w", "LineWidth", 3, "HandleVisibility","off");
                if i ~= 20
                    if i == BEP1 || i == BEP2
                        plot(survey.ProfileEastingPeak{i}, survey.ProfileNorthingPeak{i}, "-w", "LineWidth", 1.5);
                    else
                        plot(survey.ProfileEastingPeak{i}, survey.ProfileNorthingPeak{i}, "-k", "LineWidth", 1.5);
                    end
                end
            end
            legend("Profile Lines", "Location","northwest")
            xlim(xBounds)
            ylim(yBounds)
            grid on
            set(findall(gcf,'-property','FontSize'),'FontSize',12);
            set(findobj(gcf, 'Type', 'Legend'),'FontSize',11);
            set(gcf, 'Units', 'inches');
            pos = get(gcf, 'Position');
            set(gcf, 'Position', [pos(1), pos(2), 7.5, 7.5*pos(4)/pos(3)]); set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 3.5 3.5*pos(4)/pos(3)]);
            pbaspect([1,1,1])
            box on;
            %exportgraphics(gcf, [get(gcf, 'Name') '.png'], 'Resolution', 300);

    figure("Name", "BEP Stack")
            t = tiledlayout(2,1);
            t.TileSpacing = 'compact';
            t.Padding = 'compact';
        %% Line 1
            nexttile
            S = survey.ProfileRiverKm{BEP1,1}(1) + survey.ProfileDuneInfo.S{BEP1}.*1.60934;
            Z = survey.ProfileDuneInfo.Z{BEP1}.*0.3048;
            plot(S,Z, '-k', "LineWidth",1.1)
            hold on;
            plot(S(survey.ProfileDuneInfo.PeakIndices{BEP1}),Z(survey.ProfileDuneInfo.PeakIndices{BEP1}),'ro',"MarkerSize",6)
            plot(S(survey.ProfileDuneInfo.TroughIndices{BEP1}),Z(survey.ProfileDuneInfo.TroughIndices{BEP1}),'bo',"MarkerSize",6)
            xlim([213.4,214.4])
            ylim([-0.75,0.75])
            %xlabel("River KM (km)")
            ylabel("\Deltaz (m)")
            lgd = legend("Bed Elevation Profile", "Bedform Peak", "Bedform Trough", "Location","northeastoutside");
            %lgd.Layout.Tile = 'north';
            lgd.Units = 'normalized';
            lgd.Position(1) = 0.73;
            lgd.Position(2) = 0.87;
            grid on
            yticks([-0.75,0,0.75]);
            xticks(213.4:0.1:214.4)
            xticklabels(string(xticks))
            yticklabels(string(yticks))
            
            ax = gca;
            ax.XMinorTick = 'on';
            ax.YMinorTick = 'on';
            yticksMinor = -0.75:0.25:0.75;
            xticksMinor = 213.4:0.05:214.4;
            ax.XAxis.MinorTickValues = xticksMinor;
            ax.YAxis.MinorTickValues = yticksMinor;
            pbaspect([7,1,1])

        %% Line 2
            nexttile
            S = survey.ProfileRiverKm{BEP2,1}(1) + survey.ProfileDuneInfo.S{BEP2}.*1.60934;
            Z = survey.ProfileDuneInfo.Z{BEP2}.*0.3048;
            plot(S,Z, '-k',"LineWidth",1.1)
            hold on;
            plot(S(survey.ProfileDuneInfo.PeakIndices{BEP2}),Z(survey.ProfileDuneInfo.PeakIndices{BEP2}),'ro',"MarkerSize",6)
            plot(S(survey.ProfileDuneInfo.TroughIndices{BEP2}),Z(survey.ProfileDuneInfo.TroughIndices{BEP2}),'bo',"MarkerSize",6)
            xlim([213.4,214.4])
            ylim([-0.75,0.75])
            xlabel("River KM (km)")
            ylabel("\Deltaz (m)")
            %legend("Bed Elevation Profile", "Dune Peak", "Dune Trough")
            grid on
            yticks([-0.75,0,0.75]);
            xticks(213.4:0.1:214.4)
            xticklabels(string(xticks))
            yticklabels(string(yticks))
            
            ax = gca;
            ax.XMinorTick = 'on';
            ax.YMinorTick = 'on';
            yticksMinor = -0.75:0.25:0.75;
            xticksMinor = 213.4:0.05:214.4;
            ax.XAxis.MinorTickValues = xticksMinor;
            ax.YAxis.MinorTickValues = yticksMinor;
            pbaspect([7,1,1])

        set(findall(gcf,'-property','FontSize'),'FontSize',16);
        set(findobj(gcf, 'Type', 'Legend'),'FontSize',14);
        set(gcf, 'Units', 'inches');
        pos = get(gcf, 'Position');
        set(gcf, 'Position', [pos(1), pos(2), 12, 12*(pos(4)*3)/(pos(3)*4)]); set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 6.5 6.5*pos(4)/pos(3)]);
        box on;
        %exportgraphics(gcf, [get(gcf, 'Name') '.png'], 'Resolution', 300);
end