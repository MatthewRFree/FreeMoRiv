clear
clc
close all

addpath('.\Plotting Functions\')
addpath('..\FreeAlgorithm\MoRiverBedformIdentification\')
addpath('..\..\..\Multibeam Data\MoRiver\eHydroImports\')
addpath('..\..\MAW MATLAB\cBathym\')

%% Get Data
    load("MoRiverMultibeamData.mat")

%% QAQC 1
    for i = 1:length(MoRiverData)

        T = readtable(MoRiverData(i).Filename + ".csv");
        T = rmmissing(T);

    figure("Name",MoRiverData(i).Filename);
        tiledlayout(2,3)
        
        %% Bed Elevation
            nexttile
            scatter3(T.X.*0.3048006096, T.Y.*0.3048006096, (140 + 0.21336*MoRiverData(i).ProfileRiverMile{1,1}(1))-(T.Z.*0.3048), 1.5, (140 + 0.21336*MoRiverData(i).ProfileRiverMile{1,1}(1))-(T.Z.*0.3048), 'filled')
            view(2)
            hold on;
            colormap(turbo)
            c = colorbar;
            axis equal tight
            daspect([1,1,1]);
            clim([prctile((140 + 0.21336*MoRiverData(i).ProfileRiverMile{1,1}(1))-(T.Z.*0.3048), 2), prctile((140 + 0.21336*MoRiverData(i).ProfileRiverMile{1,1}(1))-(T.Z.*0.3048), 98)])
            title("Bed Elevation NAD83/UTM Zone 15")
            xlabel("Easting (m)")
            ylabel("Northing (m)")
            c.Label.String = 'Elevation (m)';

        %% Length
            nexttile
            qacHeatMap(cell2mat(MoRiverData(i).ProfileEastingPeak(:)),cell2mat(MoRiverData(i).ProfileNorthingPeak(:)),MoRiverData(i).L,350,"Length",T.X.*0.3048006096, T.Y.*0.3048006096);
            grid

        %% Height
            nexttile
            qacHeatMap(cell2mat(MoRiverData(i).ProfileEastingPeak(:)),cell2mat(MoRiverData(i).ProfileNorthingPeak(:)),MoRiverData(i).H,350,"Height",T.X.*0.3048006096, T.Y.*0.3048006096);
            grid

        %% Sailing Line Peak/Trough
            nexttile
            S = MoRiverData(i).ProfileRiverMile{1,1}(1) + MoRiverData(i).ProfileDuneInfo.S{1};
            Z = (460 + 0.7*MoRiverData(i).ProfileRiverMile{1,1}(1)) + MoRiverData(i).ProfileDuneInfo.Z{1};
            plot(S,Z)
            hold on;
            plot(S(MoRiverData(i).ProfileDuneInfo.PeakIndices{1}),Z(MoRiverData(i).ProfileDuneInfo.PeakIndices{1}),'ro',"MarkerSize",3)
            plot(S(MoRiverData(i).ProfileDuneInfo.TroughIndices{1}),Z(MoRiverData(i).ProfileDuneInfo.TroughIndices{1}),'bo',"MarkerSize",3)
            xlim([nanmean(S)-0.125,nanmean(S)+0.125])
            ylim([(460 + 0.7*MoRiverData(i).ProfileRiverMile{1,1}(1)-3),(460 + 0.7*MoRiverData(i).ProfileRiverMile{1,1}(1)+3)])
            title("Sailing Line Dune Peak and Trough")
            xlabel("River Mile (mi)")
            ylabel("Elevation (ft)")
        
        %% Length Histogram
            nexttile
            histogram(MoRiverData(i).L,15,'Normalization', 'pdf')
            title("Length Probability Density Plot")
            xlabel("Length (m)")
            ylabel("Probability Density")

        %% Height Histogram
            nexttile
            histogram(MoRiverData(i).H,15,'Normalization', 'pdf')
            title("Height Probability Density Plot")
            xlabel("Height (m)")
            ylabel("Probability Density")
        
        filename = sprintf("%s%s%s",".\QAQC Figures\",MoRiverData(i).Filename,".png");
        %print(gcf,filename,'-dpng','-r150')
        close all

%% QAQC 2
        surveyLength = abs(MoRiverData(i).ProfileRiverMile{1,1}(end)-MoRiverData(i).ProfileRiverMile{1,1}(1));

        cBath = cBathym(T.X.*0.3048006096, T.Y.*0.3048006096, (140 + 0.21336*MoRiverData(i).ProfileRiverMile{1,1}(1))-(T.Z.*0.3048));

        cBath = getNNxyz(cBath,0);

        c_grid      = 1.1;
        c_search    = sqrt(2);
        
        gridres     = c_grid*cBath.meanNNxyz; 
        Method = [];
        SearchRad   = c_search*gridres;
        
        cBath = getBath(cBath,cBath.xyz_ptCl,gridres,Method,SearchRad);

        duneEastingPeaks = cell2mat(MoRiverData(i).ProfileEastingPeak(:));
        duneNorthingPeaks = cell2mat(MoRiverData(i).ProfileNorthingPeak(:));
        duneEastingTroughs = cell2mat(MoRiverData(i).ProfileEastingTrough(:));
        duneNorthingTroughs = cell2mat(MoRiverData(i).ProfileNorthingTrough(:));

        % Peaks on Raster
    figure("Name",sprintf('%s%s',MoRiverData(i).Filename,"_Raster"));
        tiledlayout(1,1)
            nexttile
            showBathContf(cBath);
            hold on;
            scatter(duneEastingPeaks, duneNorthingPeaks, 6 * 1/(surveyLength^0.25),'k', 'filled')
            %scatter(duneEastingTroughs,duneNorthingTroughs,'b.')

            filename = sprintf("%s%s%s",".\QAQC Figures\",MoRiverData(i).Filename,"_Raster.png");
            %print(gcf,filename,'-dpng','-r300')
            close all

        % Peaks on Difference
    figure("Name",sprintf('%s%s',MoRiverData(i).Filename,"_RasterDiff"));
        tiledlayout(1,1)
            nexttile
            [cBath,~] = getSmoothBath(cBath,ceil(mean(MoRiverData(i).L))*0.75);
            [cBath,~] = getDiffElev(cBath);
            showBathdiffContf(cBath);
            hold on;
            scatter(duneEastingPeaks, duneNorthingPeaks, 10 * 1/(surveyLength^0.25), 'w', 'filled', 'MarkerFaceAlpha', 0.9);
            scatter(duneEastingPeaks, duneNorthingPeaks, 4 * 1/(surveyLength^0.25), 'k', 'filled', 'MarkerFaceAlpha', 0.8);

            filename = sprintf("%s%s%s",".\QAQC Figures\",MoRiverData(i).Filename,"_RasterDiff.png");
            %print(gcf,filename,'-dpng','-r300')
            close all force
    end