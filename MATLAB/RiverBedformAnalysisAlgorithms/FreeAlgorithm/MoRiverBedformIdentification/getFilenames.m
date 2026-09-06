function fileNames = getFilenames(inputpath)
% GETFILENAMES returns filenames from a directory
%   GETFILENAMES is used to get a list of all the filenames within a
%   directory.
%
%   [FILENAMES] = GETFILENAMES(INPUTPATH) takes an input path as the directory
%   INPUTPATH and returns all filenames within as FILENAMES.
%
%   Other Functions Referenced:
%       dir(...), convertCharsToStrings(...)
%
%
% -- Matthew Free 06/2025 --

%% Arguments
    arguments
        inputpath string
    end

%% Get Filenames
    fileInfo = dir(inputpath); 
    fileNames = {fileInfo.name}; 
    isFile = ~[fileInfo.isdir]; 
    fileNames = convertCharsToStrings(fileNames(isFile))';
end