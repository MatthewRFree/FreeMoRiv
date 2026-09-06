function plotGammaPDF(bin, color, markerSize)
% PLOTGAMMAPDF plots the gamma pdf parameters for each survey
%   PLOTGAMMAPDF allows for visualization of alpha and theta for each
%   survey compared with the gageHeight for each survey
%
%   PLOTGAMMAPDF(COLOR,MARKERSIZE) plots each point with the given color
%   COLOR and with the given point size MARKERSIZE. By default, COLOR will
%   be plotted as the logitudinal position of the survey RM and MARKERSIZE
%   will have a value of 50.
%
%   Other Functions Referenced:
%       load(...), length(...), fitdist(...), isempty(...), figure(...)
%       tiledlayout(...), scatter(...), xlabel(...), ylabel(...),
%       colorbar(...)
%
%
%   -- Matthew Free 07/2025 --

%% Arguments
    arguments
        bin string {mustBeMember(bin, ["on","off"])} = "off"
        color = [];
        markerSize = 50;
    end

%% Get Data
    switch bin
        case "off"
            load("MoRiverMultibeamData.mat")
            for i = 1:length(MoRiverData)
                L = MoRiverData(i).L;
                H = MoRiverData(i).H;
            
                gammaL = fitdist(L, "Gamma");
                gammaH = fitdist(H, "Gamma");
            
                alphaHeight(i) = gammaH.a;
                thetaHeight(i) = gammaH.b;
            
                alphaLength(i) = gammaL.a;
                thetaLength(i) = gammaL.b;
            
                flowDepth(i) = mean(MoRiverData(i).h);
            
                RM(i) = MoRiverData(i).RiverMileStart;
            end

        case "on"
            [RMS, L, H, h, ~, ~, ~, StatData] = binData(0.1);
            for i = 1:length(RMS)
                L = StatData.L{i,1};
                H = StatData.H{i,1};

                gammaL = fitdist(L, "Gamma");
                gammaH = fitdist(H, "Gamma");
            
                alphaHeight(i) = gammaH.a;
                thetaHeight(i) = gammaH.b;
            
                alphaLength(i) = gammaL.a;
                thetaLength(i) = gammaL.b;
            
                flowDepth(i) = h(i);
            
                RM(i) = RMS(i);
            end       
    end

    logic = isempty(color);
    if logic
        color = RM;
    end

%% Plot
    figure("Name","Gamma PDF")
        tiledlayout(2, 2);
        nexttile
        scatter(flowDepth, alphaLength, markerSize,color, '.')
        ylabel("L shape parameter, \alpha{_L}")
        xlabel("Flow Depth (m)")
    
        nexttile
        scatter(flowDepth, thetaLength, markerSize,color, '.')
        ylabel("L scale parameter, \theta{_L}")
        xlabel("Flow Depth (m)")
    
        nexttile
        scatter(flowDepth, alphaHeight, markerSize,color, '.')
        ylabel("H shape parameter, \alpha{_H}")
        xlabel("Flow Depth (m)")
    
        nexttile
        scatter(flowDepth, thetaHeight, markerSize,color, '.')
        ylabel("H scale parameter, \theta{_H}")
        xlabel("Flow Depth (m)")
    
        if logic
            cb = colorbar('eastoutside');
            cb.Label.String = 'River Mile';
            
            cb.Layout.Tile = 'east';
            cb.Position(2) = 0.25;
            cb.Position(4) = 0.5;
        end

    figure("Name","Shape vs Scale Parameter")
        tiledlayout(2, 1)
        nexttile
        scatter(alphaLength, thetaLength, markerSize, flowDepth, '.')
        xlabel("L shape parameter, \alpha{_L}")
        ylabel("L scale parameter, \theta{_L}")
        colormap("turbo")
        clim([prctile(flowDepth, 2), prctile(flowDepth, 98)])

        nexttile
        scatter(alphaHeight, thetaHeight, markerSize, flowDepth, '.')
        xlabel("H shape parameter, \alpha{_H}")
        ylabel("H scale parameter, \theta{_H}")

        cb = colorbar('eastoutside');
        cb.Label.String = 'Flow Depth';
        colormap("turbo")
        clim([prctile(flowDepth, 2), prctile(flowDepth, 98)])
        
        cb.Layout.Tile = 'east';
        cb.Position(2) = 0.25;
        cb.Position(4) = 0.5;
end