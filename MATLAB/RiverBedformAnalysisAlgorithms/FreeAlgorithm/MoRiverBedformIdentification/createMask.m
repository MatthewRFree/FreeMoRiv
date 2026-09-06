function mask = createMask(s, sInterp)
% CREATEMASK Creates a mask logical vector at locations along a vector where
% spacing has gaps.
%   CREATEMASK is used to create a mask so that points can be removed after
%   interpolation of a vector.
%
%   MASK = CREATEMASK(S, SINTERP) takes in two versions of a vector s, S
%   and SINTERP. Will return a mask MASK corresponding to SINTERP at all
%   locations where data is unevenly spaced in S.
%
%   Other Functions Referenced:
%       diff(...), mode(...), round(...), logical(...), false(...), size(...),
%       length(...)
%
%
% -- Matthew Free 05/2025 --

%% Create Mask
    % Find locations where difference is larger than common difference
        indices = diff(s) > min(1,mode(round(diff(s))));
        shift = logical([0;indices(1:end-1, 1)]);
    % Location along s vector where difference is greater
        pointStart = s(indices);
        pointEnd = s(shift);
    
    % Initialize empty mask
        mask = false(size(sInterp));
    
    % Fill the mask conditionally
    if length(pointStart) == length(pointEnd)
        for k = 1:length(pointStart)
            mask = mask | (sInterp > pointStart(k) & sInterp < pointEnd(k));
        end
    else
        for k = 1:length(pointStart)-1
            mask = mask | (sInterp > pointStart(k) & sInterp < pointEnd(k));
        end
    end
end