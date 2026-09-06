function boxAndWhiskersPlot(variable, lineWidth, markerSize)
% BOXANDWHISKERSPLOT creates box and whiskers plots for the given variable.
%   BOXANDWHISKERSPLOT is used to visualize the quartiles for the variable
%   y placed in the respective x longitudinal location. 
%
%   BOXANWHISKERSPLOT(VARIABLE) plots a box and whiskers plot for y and
%   corresponding location x on the graph. The given variable VARIABLE can
%   either plot height or length. It is set to height by default.
%
%   Other Functions Referenced:
%       length(...), prctile(...), figure(...), plot(...), scatter(...),
%       xlim(...), ylim(...), min(...), max(...), mean(...), error(...)
%
%
% -- Matthew Free 06/2025 --

%% Arguments
    arguments
        variable string {mustBeMember(variable, ["length", "height"])} = "height"
        lineWidth = 0.5;
        markerSize = 100;
    end
        
%% Gather Data
    load("MoRiverMultibeamData.mat")

    if variable == "length"
        y = {MoRiverData.L};
        x = cell2mat({MoRiverData.RiverMileStart});
    elseif variable == "height"
        y = {MoRiverData.H};
        x = cell2mat({MoRiverData.RiverMileStart});
    else
        error("invalid variable")
    end

    for i = 1:length(x)
        percentile75(i) = prctile(y{1, i}, 75);
        median(i) = prctile(y{1, i}, 50);
        percentile25(i) = prctile(y{1, i}, 25);
        percentile5(i) = prctile(y{1, i}, 5);
        percentile95(i) = prctile(y{1, i}, 95);
    end

%% Plot Data
    figure("Name","Box and Whiskers Plot")
        for i = 1:length(x)
            plot([x(i),x(i)],[percentile75(i), percentile25(i)], '-k', LineWidth=lineWidth)
            hold on;
        end
        for i = 1:length(x)
            scatter(x(i),median(i), markerSize, '.');
            hold on;
        end
        xlim([min(x) - mean(x)/3, max(x) + mean(x)/3])
        ylim([0, max(median) + mean(median)])
end