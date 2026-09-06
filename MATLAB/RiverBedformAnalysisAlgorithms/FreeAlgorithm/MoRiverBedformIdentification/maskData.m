function props = maskData(props, mask)
% MASKDATA removes data within a specified range.
%   MASKDATA uses a mask from the interpolated longitudinal vector and
%   removes and data points that lie within any part of the logical mask 
%   that is true
%
%   PROPS = MASKDATA(PROPS, MASK) removes all data from the data structure
%   PROPS and returns that data structure PROPS. PROPS structure is the 
%   output of the duneLengthHeight function.
%
%   Other Functions Referenced:
%       length(...), false(...), any(...), isnan(...)
%
%
% -- Matthew Free 06/2025 --

%% Remove Dune Characteristics
    % Create Dune Mask
        numDunes = length(props.troughIndices) - 1;
        badDuneMask = false(numDunes, 1);
    
        for i = 1:numDunes
            iStart = props.troughIndices(i);
            iEnd   = props.troughIndices(i + 1);
    
            if any(mask(iStart:iEnd))
                badDuneMask(i) = true;
            end
        end

    % Remove Dunes for Each Field in Props
        fields = ["inclinedLength", "verticalHeight", "slope", "inclinedAngle", ...
              "lengthStoss", "lengthLee", "heightStoss", "heightLee", ...
              "totalLength", "avgHeight"];
    
        for f = fields
            props.(f)(badDuneMask) = NaN;
        end
        
        valid = ~isnan(props.inclinedLength);
        for f = fields
            props.(f) = props.(f)(valid);
        end

%% Edit Trough and Peak Indices
    if ~isempty(props.troughIndices)
        % Invert Mask and save valid troughs
            newTroughIndices = props.troughIndices([~badDuneMask; true]);
        
        % Find start and end of invalid troughs
            badTroughStart = props.troughIndices([badDuneMask; false]);
            badTroughEnd = props.troughIndices([false; badDuneMask]);
        
        % Create mask for peaks within the span of bad troughs
            badPeakMask = false(size(props.peakIndices));
        
            for k = 1:length(badTroughStart)
                iStart = badTroughStart(k);
                iEnd   = badTroughEnd(k);
                badPeakMask = badPeakMask | (props.peakIndices > iStart & props.peakIndices < iEnd);
            end
    
        % Invert Mask and save valid peaks
            newPeakIndices = props.peakIndices(~badPeakMask);
    
        % Save to Data structure for output
            props.troughIndices = newTroughIndices;
            props.peakIndices = newPeakIndices;
        % NaN out masked values for S and Z and completely remove for Coords
            props.smoothS(mask) = NaN;
            props.smoothZ(mask) = NaN;
        
            props.Eastings = props.Eastings(~mask);
            props.Northings = props.Northings(~mask);
            props.Depths = props.Depths(~mask);
    end
end