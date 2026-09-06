classdef cBathym
    %% *******************************************************************
    % FUNCTION CLASS DESCRIPTION
    % ...
    
    %% *******************************************************************
    % VERSION NOTES
    % Version 1.1.0.0

    %% *******************************************************************
    % PROPERTIES AND INITIALIZATION

    properties  % data container definition to define the entire class
        xyz         % raw data %
        n_xyz       % number of xyz raw points %
        meanNNxyz   % mean nearest neighbor dist. in xy plane %
        xyz_ptCl    % raw data in point cloud object format %
        Bathxvec    % vector of bathymetry x-locations %
        Bathyvec    % vector of bathymetry y-locations %
        Bathz       % interpolated z elevation bathymetry field %
        Bathz_s     % smoothed z elevation bathymetry %
        Bathz_diff  % elevation difference relative to smoothed %
    end

    methods     % class initialization methods
        function obj=cBathym(X,Y,Z)
            obj.xyz = [X(:) Y(:) Z(:)];
            obj.xyz_ptCl = pointCloud(obj.xyz); 
            [obj.n_xyz,~] = size(obj.xyz);
        end
    end
    
    %% *******************************************************************
    % CLASS FUNCTIONS
    methods (Static)
        function color = getColor(s)
            n = 256;
            if s == "rwb"
                whiteBandRatio = 0.01;
                colorCurvePower = 0.6;

                numberOfWhiteCells = round(n * whiteBandRatio);
                numberOnEachSide = round((n - numberOfWhiteCells) / 2);
                x = linspace(0, 1, numberOnEachSide)';
                equation = x.^colorCurvePower;
    
                r1 = equation;
                g1 = equation;
                b1 = ones(numberOnEachSide, 1);
    
                r2 = ones(numberOnEachSide, 1);
                g2 = flip(equation);
                b2 = flip(equation);
    
                rW = ones(numberOfWhiteCells, 1);
                gW = ones(numberOfWhiteCells, 1);
                bW = ones(numberOfWhiteCells, 1);
    
                color = [r1 g1 b1; rW gW bW; r2 g2 b2];
            elseif s == "rb"
                r = linspace(0, 1, n)';
                g = zeros(n, 1);
                b = linspace(1, 0, n)';

                color = [r g b];
            else
                color = 'turbo';
            end
        end
    end
    methods
        %% 1. Data visualization methods
        function showBathContf(obj)
            [X,Y] = meshgrid(obj.Bathxvec,obj.Bathyvec);

            contourf(X,Y,obj.Bathz,256,'EdgeColor','none', "HandleVisibility","off");
            daspect([1 1 1]);
            xlabel('easting'), ylabel('northing'); zlabel('z')
            colormap("turbo")
        end
        function showBathdiffContf(obj)
            [X,Y] = meshgrid(obj.Bathxvec,obj.Bathyvec);
            
            contourf(X,Y,obj.Bathz_diff,256,'EdgeColor','none', "HandleVisibility","off");
            daspect([1 1 1]);
            xlabel('easting'), ylabel('northing'); zlabel('\Deltaz')
            cstd = std(obj.Bathz_diff(:),'omitnan');
            colormap(obj.getColor("rwb"))
            clim([-cstd cstd])
        end

        %% 2. Raw bathymetry (.xyz) pre processing
        function obj = getNNxyz(obj,Plot)
            ptCloud = obj.xyz_ptCl; % load raw pt cloud

            % get rid of z location, since I only care xy nearest here
            XYZ = ptCloud.Location(:,1:2);  % get locations
            XYZ(:,3) = 0;                   % remove z
            ptCloudNN = pointCloud(XYZ);    % re-create point cloud
            
            NNdist = zeros(1,obj.n_xyz);  % initialize
            for i = 1:obj.n_xyz
                point = ptCloudNN.Location(i,:);
                [~,dists] = findNearestNeighbors(ptCloudNN,point,2);
                NNdist(i) = dists(2);
            end
            
            obj.meanNNxyz = mean(NNdist);
        end

        %% 3. Bathymetry interpolation
        function obj = getBath(obj,ptCloud,gridres,Method,SearchRad)
            if isempty(Method)
                Method = "idw";
            end
            if isempty(SearchRad)
                SearchRad = sqrt(2)*gridres;
            end
            [obj.Bathz,xlims,ylims] = pc2dem(ptCloud,gridres,"CornerFillMethod",Method,"SearchRadius",SearchRad);
            xvec = xlims(1):gridres:xlims(2);
            yvec = ylims(1):gridres:ylims(2); 
            obj.Bathxvec = xvec;
            obj.Bathyvec = yvec; 
        end
        function [obj,Bathz_s] = getSmoothBath(obj,wind) % wind in units of # adjacent cells
            Bathz_s = smoothdata2(obj.Bathz,'movmean',wind);
            obj.Bathz_s = Bathz_s;
        end
        function [obj,Bathz_diff] = getDiffElev(obj)
            Bathz_diff = obj.Bathz - obj.Bathz_s;
            obj.Bathz_diff = Bathz_diff;
        end
    end

end