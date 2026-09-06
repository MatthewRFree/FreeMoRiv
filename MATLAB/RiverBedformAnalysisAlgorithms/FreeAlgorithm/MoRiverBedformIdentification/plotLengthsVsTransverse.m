function plotLengthsVsTransverse(avgLengths)
% PLOTLENGTHVSTRANSVERSE Plots average dune length in corresponding
% location from sailing line.
%   PLOTLENGTHVSTRANSVERSE allows for visualization of length and height
%   scales over the transverse location from the sailing line.
%
%   PLOTLENGTHVSTRANSVERSE(AVGLENGTHS) takes an argument of a vector of
%   dune lengths AVGLENGTHS.
%   Other Functions Referenced:
%       figure(...), plot(...), title(...), xlabel(...), ylabel(...),
%       ylim(...), xlim(...), max(...), min(...)
%
%
% -- Matthew Free 05/2025 --

%% Arguments
    arguments
        avgLengths double
    end

    % Position vector of distances (m) from sailing line
        channelPosition = [-100 -90 -80 -70 -60 -50 -40 -30 -20 -10 0 10 20 30 40 50 60 70 80 90 100];
        
%% Plot
    figure("Name","Dune Length Across the Transverse")
        plot(channelPosition(avgLengths~=0), avgLengths(avgLengths~=0));
        title("Dune Length Across the Transverse")
        xlabel("Channel Position From Sailing Line (m)")
        ylabel("Average Dune Length (m)")
        ylim([0, max(avgLengths)*1.2])
        xlim([min(channelPosition(avgLengths~=0)), max(channelPosition(avgLengths~=0))]);
end