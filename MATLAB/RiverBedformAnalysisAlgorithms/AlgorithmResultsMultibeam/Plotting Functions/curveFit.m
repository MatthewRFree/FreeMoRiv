function [a,m,fitX,fitY,paramFit] = curveFit(x, y, fitX)
% CURVEFIT fits a curve to a given set of data X and Y
%   CURVEFIT uses a model a * x ^ b to fit a curve to the X Y data.
%
%   [A,B,...] = CURVEFIT(X,Y) returns the coefficients A and B
%   corresponding to the power law model.
%
%   [...,FITX,FITY] = CURVEFIT(...,FITX) returns a sampling of the curve
%   for the input x vector FITX.
%
%   [...,paramFit] = CURVEFIT(...) returns the stat values for the fit
%   function ax^b and the 90% intercept values.
%
%   Other Functions Referenced:
%       nlinfit(...), fitnlm(...)
%
%
% -- Matthew Free 06/2025 --

%% Arguments
    arguments
        x double
        y double
        fitX double = []
    end

%% Parameters
    model = @(b,x) b(1) * x.^b(2);
    b0 = [1, 1];

%% Fit Curve
    beta = nlinfit(x, y, model, b0);
    
    mdl = fitnlm(x,y,model,b0);

    a = beta(1);
    m = beta(2);

    fitY = a.*(fitX.^m);

    % Parameter confidence intervals (90%)
        paramFit.R2 = mdl.Rsquared.Ordinary;
        paramFit.p = mdl.Coefficients.pValue;
        paramFit.RMSE = mdl.RMSE;

        aData = y./(x.^m);
        paramFit.a95 = prctile(aData, 95); % 90% CI
        paramFit.a5 = prctile(aData,5);
end