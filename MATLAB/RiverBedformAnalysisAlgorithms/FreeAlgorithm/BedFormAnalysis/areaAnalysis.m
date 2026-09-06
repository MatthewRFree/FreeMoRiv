function [signed, unsigned] = areaAnalysis(x1, y1, x2, y2)
% AREAANALYSIS Analyzes the waveforms using area.
%   AREAANALYSIS calculates the area between waveforms and find the difference
%   between them, both signed and unsigned
%
%   [SIGNED,UNSIGNED] = AREAANALYSIS(X1,Y1,X2,Y2) computes the signed and
%   unsigned area differences between two waveforms defined by (X1,Y1) and 
%   (X2,Y2). Signed area represents net difference, while unsigned area 
%   represents total absolute difference.
%
%   Other Functions Referenced:
%       integral(...), abs(...), sum(...), fprintf(...)
%
%
% -- Matthew Free 06/2024 --

%% Arguments
    arguments
        x1 double {mustBeVector}
        y1 double {mustBeVector}
        x2 double {mustBeVector}
        y2 double {mustBeVector}
    end
    
%% Process
    % integrates both waveforms
        [S1, area1] = integral(x1, y1);
        [S2, area2] = integral(x2, y2);
    
    % calculates the signed and unsigned areas between the waveforms
        signed = S2 - S1;
        unsigned = sum(abs(area2-area1));
    
    % prints the signed and unsigned areas
        fprintf("The Signed Area is %.2f (ft^2).\nThe Unsigned Area is %.2f (ft^2).\n", signed, unsigned);
end

