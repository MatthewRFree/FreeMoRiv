function [MOData_Struct, index] = importData(filename, sheet)
% IMPORTDATA Reads data as a column vector from an excel column into a specified field.
%   IMPORTDATA is used to fill a data structure procedurally from a
%   spreadsheet containing data on multiple different columns and on
%   multiple different sheets.
%
%   [MODATA_STRUCT,INDEX] = IMPORTDATA(FILENAME,SHEET) reads data from the
%   file FILENAME and on the excel sheet SHEET into the data structure
%   MODATA_STRUCT. Returns the index of the last object to be read INDEX.
%
%   Other Functions Referenced:
%       readExcelColumn(...)
%
%
% -- Matthew Free 06/2024 --

%% Arguments
    arguments
        filename string
        sheet string
    end

%% Fill Data Structure
    addpath("..\..\..\..\Single Beam Data\")
    % APRIL
    n = 1;

    MOData_Struct(n).x = readExcelColumn(filename, sheet, 'A');
    MOData_Struct(n).offset = readExcelColumn(filename, sheet, 'B');
    MOData_Struct(n).waterElevation = readExcelColumn(filename, sheet, 'C');
    MOData_Struct(n).z = readExcelColumn(filename, sheet, 'D');
    MOData_Struct(n).date = "APRIL 4-6";
    % MAY
    n = n + 1;

    MOData_Struct(n).x = readExcelColumn(filename, sheet, 'F');
    MOData_Struct(n).offset = readExcelColumn(filename, sheet, 'G');
    MOData_Struct(n).waterElevation = readExcelColumn(filename, sheet, 'H');
    MOData_Struct(n).z = readExcelColumn(filename, sheet, 'I');
    MOData_Struct(n).date = "MAY 26";
    % June
    n = n + 1;

    MOData_Struct(n).x = readExcelColumn(filename, sheet, 'K');
    MOData_Struct(n).offset = readExcelColumn(filename, sheet, 'L');
    MOData_Struct(n).waterElevation = readExcelColumn(filename, sheet, 'M');
    MOData_Struct(n).z = readExcelColumn(filename, sheet, 'N');
    MOData_Struct(n).date = "JUNE 30";
    % November
    n = n + 1;

    MOData_Struct(n).x = readExcelColumn(filename, sheet, 'P');
    MOData_Struct(n).offset = readExcelColumn(filename, sheet, 'Q');
    MOData_Struct(n).waterElevation = readExcelColumn(filename, sheet, 'R');
    MOData_Struct(n).z = readExcelColumn(filename, sheet, 'S');
    MOData_Struct(n).date = "NOVEMBER 22";

    % index variable specifies the number of dates included/ read
    index = n;
end
