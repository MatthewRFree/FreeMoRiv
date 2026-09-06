function prominence = calculateProminence(S,Z)
% CALCULATEPROMINENCE Calculates dune prominence using wavelet analysis.
%   CALCULATEPROMINENCE analyzes interpolated dune profiles using the
%   wavelet transform to compute the average Fourier period and estimate 
%   dune prominence.
%
%   PROMINENCE = DUNEPROMINENCE(S,Z) performs a wavelet transform on S and Z. 
%   The global wavelet spectrum is analyzed to find the average normalized 
%   Fourier period, which is converted to an estimated dune prominence PROMINENCE.
%
%   Other Functions Referenced:
%       getSprofileInterp(...), getWtHPF(...), curveSmoothing(...),
%       cwt(...), mean(...), diff(...), chi2inv(...), var(...), dot(...),
%       sprintf(...), exist(...), load(...), isempty(...), ones(...),
%       sum(...)
%
%
% -- Matthew Free 07/2025 --


%% Arguments
    arguments
        S double
        Z double
    end
    
%% Wavelet Transform Analysis
    dx = mean(diff(S));
    fs = 1 / dx;
    [wt, f] = cwt(smoothZ, 'amor', fs);
    power = abs(wt).^2;

    % Calculate fourier period and global wavelet spectrum
    fourierPeriod = 1 ./ f;
    gWaveletSpectrum = mean(power, 2);
    
    % Calculate 95% significant global wavelet spectrum

        % Assume signal is noise; create vector of variance around the mean
        noise = var(Z) * ones(size(gWaveletSpectrum));
        
        % Each parameter has two DOF, Re and Im
        chiSquare = chi2inv(0.95, 2);

        % Variance of the signal * the critical value normalized by DOF
        gSignificance = noise * chiSquare / 2;
    
    % Normalized GWS (power) from the GWS/95%GWS
    normalizedGWS = gWaveletSpectrum ./ gSignificance;
    
    % Find the average value under the curve (fourierPeriod vs normalizedGWS)
    averagePeriod = dot(fourierPeriod, normalizedGWS) / sum(normalizedGWS);
    
    % Return prominence value taking the average Period value (lamda) in meters and
    % converting to a dune height in feet using typical relationships and a
    % correction factor.
    prominence = (0.062/5)*averagePeriod;
end