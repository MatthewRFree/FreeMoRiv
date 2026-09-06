clear
clc
close all

addpath('..\Plotting Functions\')
addpath('..\..\FreeAlgorithm\MoRiverBedformIdentification\')
addpath('..\..\..\..\Multibeam Data\MoRiver\eHydroImports\')
addpath('..\..\..\MAW MATLAB\cBathym\')

%% Parameters
    surveysToCheck = [38 58 188 242 361];
    prominenceValues = ["0.10", "0.15", "0.20", "0.25", "0.30", "0.40", "0.50", "0.60"];

%% Get Data
    for j = 1:length(prominenceValues)
        filename = sprintf("%s%s%s", "MoRiverMultibeamDataProminence", prominenceValues(j), ".mat");
        load(filename)
        filenames = [MoRiverData.Filename] + ".csv";
    
    %% Figure 1
        for i = surveysToCheck
    
            T = readtable(filenames(i));
            T = rmmissing(T);
    
        figure("Name",sprintf('%s%s%s',MoRiverData(i).Filename,"_Profile",prominenceValues(j)));
            tiledlayout(3,1)
    
            %% Sailing Line Peak/Trough
                nexttile
                S = MoRiverData(i).ProfileRiverMile{1,1}(1) + MoRiverData(i).ProfileDuneInfo.S{1};
                Z = (460 + 0.7*MoRiverData(i).ProfileRiverMile{1,1}(1)) + MoRiverData(i).ProfileDuneInfo.Z{1};
                plot(S,Z)
                hold on;
                plot(S(MoRiverData(i).ProfileDuneInfo.PeakIndices{1}),Z(MoRiverData(i).ProfileDuneInfo.PeakIndices{1}),'ro',"MarkerSize",3)
                plot(S(MoRiverData(i).ProfileDuneInfo.TroughIndices{1}),Z(MoRiverData(i).ProfileDuneInfo.TroughIndices{1}),'bo',"MarkerSize",3)
                xlim([nanmean(S)-0.30,nanmean(S)+0.30])
                ylim([(460 + 0.7*MoRiverData(i).ProfileRiverMile{1,1}(1)-3),(460 + 0.7*MoRiverData(i).ProfileRiverMile{1,1}(1)+3)])
                title("Sailing Line Dune Peak and Trough")
                xlabel("River Mile (mi)")
                ylabel("Elevation (ft)")
            %% +10m Line Peak/Trough
                nexttile
                S = MoRiverData(i).ProfileRiverMile{2,1}(1) + MoRiverData(i).ProfileDuneInfo.S{2};
                Z = (460 + 0.7*MoRiverData(i).ProfileRiverMile{2,1}(1)) + MoRiverData(i).ProfileDuneInfo.Z{2};
                plot(S,Z)
                hold on;
                plot(S(MoRiverData(i).ProfileDuneInfo.PeakIndices{2}),Z(MoRiverData(i).ProfileDuneInfo.PeakIndices{2}),'ro',"MarkerSize",3)
                plot(S(MoRiverData(i).ProfileDuneInfo.TroughIndices{2}),Z(MoRiverData(i).ProfileDuneInfo.TroughIndices{2}),'bo',"MarkerSize",3)
                xlim([nanmean(S)-0.30,nanmean(S)+0.30])
                ylim([(460 + 0.7*MoRiverData(i).ProfileRiverMile{2,1}(1)-3),(460 + 0.7*MoRiverData(i).ProfileRiverMile{2,1}(1)+3)])
                title("+10 m Dune Peak and Trough")
                xlabel("River Mile (mi)")
                ylabel("Elevation (ft)")
            %% -10m Line Peak/Trough
                nexttile
                S = MoRiverData(i).ProfileRiverMile{3,1}(1) + MoRiverData(i).ProfileDuneInfo.S{3};
                Z = (460 + 0.7*MoRiverData(i).ProfileRiverMile{3,1}(1)) + MoRiverData(i).ProfileDuneInfo.Z{3};
                plot(S,Z)
                hold on;
                plot(S(MoRiverData(i).ProfileDuneInfo.PeakIndices{3}),Z(MoRiverData(i).ProfileDuneInfo.PeakIndices{3}),'ro',"MarkerSize",3)
                plot(S(MoRiverData(i).ProfileDuneInfo.TroughIndices{3}),Z(MoRiverData(i).ProfileDuneInfo.TroughIndices{3}),'bo',"MarkerSize",3)
                xlim([nanmean(S)-0.30,nanmean(S)+0.30])
                ylim([(460 + 0.7*MoRiverData(i).ProfileRiverMile{3,1}(1)-3),(460 + 0.7*MoRiverData(i).ProfileRiverMile{3,1}(1)+3)])
                title("-10 m Dune Peak and Trough")
                xlabel("River Mile (mi)")
                ylabel("Elevation (ft)")


            filename = sprintf("%s%s%s%s%s",".\Prominence Sensitivity Figures\",MoRiverData(i).Filename,"_Profile", prominenceValues(j), ".png");
            print(gcf,filename,'-dpng','-r150')
            close all
    
    %% Figure 2
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
    
            % Peaks on Difference
        figure("Name",sprintf('%s%s%s',MoRiverData(i).Filename,"_Raster",prominenceValues(j)));
            tiledlayout(1,1)
                nexttile
                [cBath,~] = getSmoothBath(cBath,ceil(mean(MoRiverData(i).L))*0.75);
                [cBath,~] = getDiffElev(cBath);
                showBathdiffContf(cBath);
                hold on;
                scatter(duneEastingPeaks, duneNorthingPeaks, 10 * 1/(surveyLength^0.25), 'w', 'filled', 'MarkerFaceAlpha', 0.9);
                scatter(duneEastingPeaks, duneNorthingPeaks, 4 * 1/(surveyLength^0.25), 'k', 'filled', 'MarkerFaceAlpha', 0.8);
    
                filename = sprintf("%s%s%s%s%s",".\Prominence Sensitivity Figures\",MoRiverData(i).Filename,"_Raster", prominenceValues(j), ".png");
                print(gcf,filename,'-dpng','-r300')
                close all force
        end
    end
