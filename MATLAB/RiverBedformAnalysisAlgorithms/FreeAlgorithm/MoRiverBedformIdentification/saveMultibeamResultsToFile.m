function saveMultibeamResultsToFile(filename, Data, s, path)
% SAVEMULTIBEAMRESULTSTOFILE Saves the Data and plots for each date run.
%   SAVEMULTIBEAMRESULTSTOFILE allows for viewing, and exporting of data and plots.
%
%   SAVEMULTIBEAMRESULTSTOFILE(FILENAME, DATA) saves the data structure DATA with
%   the given name FILENAME as well as plots and save figures for DATA with
%   a given name FILENAME.
%
%   SAVEMULTIBEAMRESULTSTOFILE(..., S, PATH) choose to save data and figures or just plot 
%   figures with the selection value S. If S is 1, data DATA and figures
%   will be saved in a path location. If S is 0, only figures will be
%   created. S is 1 by default. Choose a specific path PATH for the folder
%   that results will be saved to.
%
%   Other Functions Referenced:
%       addpath(...), sprintf(...), elevationMap(...), heatMap(...),
%       save(...), savefig(...)
%
%
%   -- Matthew Free 06/2025 --

%% Arguments
    arguments
        filename string
        Data
        s {mustBeMember(s, [0,1])} = 1;
        path string = "..\AlgorithmResultsMultibeam\MoRiver\";
    end

%% Plot and Save
    addpath(path)

    basename = filename;

    dataFilename = sprintf("%s%s", basename, "_data");
    %elevationMapFilename = sprintf("%s%s", basename, "_elevation_figure");
    %heatMapFilename1 = sprintf("%s%s", basename, "_dune_height");
    %heatMapFilename2 = sprintf("%s%s", basename, "_dune_length");

    %eHandle = elevationMap(Data.Eastings, Data.Northings, Data.Elevation);
    %[hHandle, lHandle] = heatMap(cell2mat(Data.duneEastings.peaks(:)), cell2mat(Data.duneNorthings.peaks(:)), Data.c1, Data.c2);
    
    %s = input("Enter to save: ");

    if s == 1
        save(sprintf("%s%s",path, dataFilename), "Data");

        %savefig(eHandle, sprintf("%s%s",path, elevationMapFilename));
        %savefig(hHandle, sprintf("%s%s",path, heatMapFilename1));
        %savefig(lHandle, sprintf("%s%s",path, heatMapFilename2));
    end
end