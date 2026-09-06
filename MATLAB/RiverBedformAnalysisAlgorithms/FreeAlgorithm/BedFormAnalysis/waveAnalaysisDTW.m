function [D,d] = waveAnalaysisDTW(y1, y2)
% WAVEANALYSISDTW Evaluates the DTW cost comparing two linescans at different months
%   WAVEANALYSISDTW takes in two linescans at different months and returns
%   the total cost representing how similar the signals are.
%
%   [D, d] = WAVEANALYSISDTW(Y1,Y2) compares two linescans Y1 and Y2 using 
%   dynamic time warping (DTW). This function computes the cumulative DTW 
%   cost matrix and returns the normalized DTW cost/unit length D and the vector of 
%   path costs d along the path.
%
%   Other Functions Referenced:
%       interp1(...), inf(...), abs(...), min(...), fprintf(...)
%
%
% -- Matthew Free 06/2024 --

%% Arguments
    arguments
        y1 double {mustBeVector}
        y2 double {mustBeVector}
    end

%% Process
    % Downsample large vectors for memory efficiency
        if length(y1) > 10000
            y1 = interp1(y1, linspace(1, numel(y1), 10000));
            y2 = interp1(y2, linspace(1, numel(y2), 10000));
        end
    
        % Ensure column vector format
        y1 = y1(:);
        y2 = y2(:);
    
        % DTW matrix initialization
        M = inf(length(y1) + 1, length(y2) + 1);
        M(1, 1) = 0;
    
        % Fill DTW matrix
        for i = 2:length(y1)+1
            for j = 2:length(y2)+1
                cost = abs(y1(i-1) - y2(j-1));
                M(i, j) = cost + min([M(i-1, j), M(i, j-1), M(i-1, j-1)]);
            end
        end
    
        % Traceback
        x = length(y1) + 1;
        y = length(y2) + 1;
        d = M(x, y);
    
        while x > 2 && y > 2
            [~, idx] = min([M(x-1, y), M(x, y-1), M(x-1, y-1)]);
            switch idx
                case 1
                    x = x - 1;
                case 2
                    y = y - 1;
                case 3
                    x = x - 1;
                    y = y - 1;
            end
            d(end+1) = M(x, y);
        end
    
    % Average DTW path cost
    D = mean(d)/mean([length(y1), length(y2)]);
    
    % Print result
    fprintf("The DTW cost was %.2f\n", D);
end