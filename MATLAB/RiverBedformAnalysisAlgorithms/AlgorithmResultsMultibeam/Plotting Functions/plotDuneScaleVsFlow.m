function plotDuneScaleVsFlow(markerSize)
% PLOTDUNESCALEVSFLOW Takes Length and Height values and plots against flow depth
%   PLOTDUNESCALEVSFLOW allows for a scatter visulaization of how length 
%   and height compare to flow. A fitted line is plotted over.
%
%   PLOTDUNESCALEVSFLOW(MARKERSIZE) takes in inputs for the
%   scatter point size MARKERSIZE
%
%   Other Functions Referenced:
%       length(...), load(...), find(...), tiledlayout(...), scatter(...),
%       linspace(...), curveFit(...), semilogy(...), xlim(...), ylim(...),
%       xlabel(...), ylabel(...), legend(...)
%
%
%   -- Matthew Free 06/2025 --

%% Arguments
    arguments
        markerSize double {mustBeInRange(markerSize, 1, 250)} = 36
    end

    data = "mo";

%% Get Data
    load("MoRiverMultibeamDataProminence0.334.mat")
    load("MissRiverMultibeamData.mat")
    load("SingleBeamFlowDepthVariables.mat");
    load("VicksburgFlowDepthVariables.mat");

    if data == "mo"
        % date = datetime("2020-01-01");
        % mask = [MoRiverData.Date] < date;
        % MoRiverData(mask) = [];
        % mask = [MoRiverData.RiverMileEnd]-[MoRiverData.RiverMileStart] < 1;
        % MoRiverData(mask) = [];
        for i = 1:length(MoRiverData)
            averageOverallLength(i) = mean(MoRiverData(i).L);
            averageOverallHeight(i) = mean(MoRiverData(i).H);
            averageOverallDepth(i) = mean(MoRiverData(i).h);
        end

        singleBeamLength = [aprilLength; mayLength; juneLength];
        singleBeamHeight = [aprilHeight; mayHeight; juneHeight];
        singleBeamDepth = 0.3048.*[aprilDepth; mayDepth; juneDepth];
    
        indices = find(averageOverallDepth > 0 & averageOverallDepth < 50); % remove errors
    
    %% Plot Data
        figure("Name","Dune Scale vs Flow Depth")
            tiledlayout(2, 1)
            nexttile
            scatter(averageOverallDepth(indices), averageOverallLength(indices), markerSize, "HandleVisibility","off")
            hold on;
            scatter(singleBeamDepth, singleBeamLength, '*', "HandleVisibility","off")
            x = linspace(0, 30, 1000);
            y1 = 0.66*x.^1.67;
            y2 = 6.96*x.^0.95;
            [A,B,fitX, fitY] = curveFit(averageOverallDepth(indices), averageOverallLength(indices), 3:0.01:12);
            semilogy(x, y1, x, y2, fitX, fitY)
            xlim([2,13])
            ylim([6,23])
            legend("Vicksburg L=0.66*H^{1.67}", "B&V2017 L=6.96*H^{0.95}", sprintf("Fitted Model L=%f*H^{%f}",A,B))
            ylabel("Bedform Length (m)")
    
            nexttile
            scatter(averageOverallDepth(indices), averageOverallHeight(indices), markerSize, "HandleVisibility","off")
            hold on;
            scatter(singleBeamDepth, singleBeamHeight, '*', "HandleVisibility","off")
            y1 = 0.021*x.^1.69;
            y2 = 0.13*x.^0.94;
            [A,B,fitX, fitY] = curveFit(averageOverallDepth(indices), averageOverallHeight(indices), 3:0.01:12);
            semilogy(x, y1, x, y2, fitX, fitY)
            xlim([2,12])
            ylim([0,1])
            legend("Vicksburg A=0.021*H^{1.69}", "B&V2017 A=0.13*H^{0.94}", sprintf("Fitted Model A=%f*H^{%f}",A,B))
            xlabel("Flow Depth (m)")
            ylabel("Bedform Amplitude (m)")

    elseif data == "miss"
        for i = 1:length(MoRiverData)
            moLength(i) = mean(MoRiverData(i).L);
            moHeight(i) = mean(MoRiverData(i).H);
            moDepth(i) = mean(MoRiverData(i).h);
        end
        
        mask = [MissRiverData.RiverMileEnd]-[MissRiverData.RiverMileStart] < 1;
        MissRiverData(mask) = [];

        for i = 1:length(MissRiverData)
            missLength(i) = mean(MissRiverData(i).L);
            missHeight(i) = mean(MissRiverData(i).H);
            missDepth(i) = mean(MissRiverData(i).h);
        end

        singleBeamLength = L;
        singleBeamHeight = H;
        singleBeamDepth = D;
    
        indices1 = find(moDepth > 0 & moDepth < 50); % remove errors
        indices2 = find(missDepth > 0 & missDepth < 50); % remove errors
    
    %% Plot Data
        figure("Name","Dune Scale vs Flow Depth")
            tiledlayout(2, 1)
            nexttile
            scatter(moDepth(indices1), moLength(indices1), markerSize, "blue")
            hold on;
            scatter(missDepth(indices2), missLength(indices2), markerSize, "red")
            scatter(singleBeamDepth, singleBeamLength, 'g*')
            x = linspace(0, 30, 1000);
            y1 = 0.66*x.^1.67;
            y2 = 6.96*x.^0.95;
            semilogy(x, y1, x, y2)
            xlim([0,30])
            ylim([4.25,140])
            legend("Missouri", "Mississippi", "Vicksburg", "Vicksburg L=0.66*H^{1.67}", "B&V2017 L=6.96*H^{0.95}")
            ylabel("Bedform Length (m)")
            set(gca, 'YScale', 'log')
    
            nexttile
            scatter(moDepth(indices1), moHeight(indices1), markerSize, "blue")
            hold on;
            scatter(missDepth(indices2), missHeight(indices2), markerSize, "red")
            scatter(singleBeamDepth, singleBeamHeight, 'g*')
            y1 = 0.021*x.^1.69;
            y2 = 0.13*x.^0.94;
            semilogy(x, y1, x, y2)
            xlim([0,30])
            ylim([0.05,10])
            legend("Missouri", "Mississippi", "Vicksburg", "Vicksburg A=0.021*H^{1.69}", "B&V2017 A=0.13*H^{0.94}")
            xlabel("Flow Depth (m)")
            ylabel("Bedform Amplitude (m)")
            set(gca, 'YScale', 'log')
    end
end