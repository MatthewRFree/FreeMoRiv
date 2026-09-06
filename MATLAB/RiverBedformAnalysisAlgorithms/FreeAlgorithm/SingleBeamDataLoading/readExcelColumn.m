function columnData = readExcelColumn(filename, sheet, column, cEnd)
% READEXCELCOLUMN Reads and returns a specified excel column
%   READEXCELCOLUMN reads a column from a specific sheet and file in excel.
%
%   COLUMNDATA = READEXCELCOLUMN(FILENAME,SHEET,COLUMN) reads from an excel
%   file FILENAME on the specified sheet SHEET and from the column COLUMN.
%   It returns COLUMNDATA as a vector from the column being read.
%
%   [...] = READEXCELCOLUMN(...,CEND) takes a specified value for CEND the
%   last item in the column to export. CEND by default is set at 180000.
%
%   Other Functions Referenced:
%       sprintf(...), readtable(...), rmmissing(...), isnumeric(...)
%
%
% -- Matthew Free 06/2024 --

%% Arguments
    arguments
        filename string
        sheet string
        column string
        cEnd = 180000
    end

    % Get column range
    % specifies between 3 and 180000, any NaN values will be removed after
    range = sprintf("%s3:%s%d", column, column, cEnd);
    
    % read the column from spreadsheet
    columnData = readtable(filename,'Sheet', sheet,'Range', range);

    % remove all NaN values
    columnData = rmmissing(columnData, 'DataVariables', @isnumeric);
end
