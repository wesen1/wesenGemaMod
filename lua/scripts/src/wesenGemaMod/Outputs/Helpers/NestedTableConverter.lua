---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TableUtils = require("Utils/TableUtils");

---
-- Converts a nested table to a single table.
--
-- @type NestedTableConverter
--
local NestedTableConverter = {};


---
-- Returns the rows of a table in the format { [1] => [row1 entries], [2] => [row2 Entries], ... }.
-- Merges all sub tables into the main table schema.
--
-- @tparam table _table The table content in the format { [1] => [row1 entries], [2] => [row2 entries], ... }
-- @tparam table _rows The already converted rows
-- @tparam int[] _insertedRows The inserted rows in the format {[y] = amountInsertedRows}
-- @tparam int[] _insertedColumns The inserted columns in the format {[x] = {[y] = amountInsertedColumns}}
-- @tparam int _mainTableWidth The width of the main table
--
-- @treturn table The table with merged sub tables in the format { [1] => [row1 entries], [2] => [row2 entries], ... }
--
function NestedTableConverter:convertTable(_table, _rows, _insertedRows, _insertedColumns, _mainTableWidth)

  local rows = {};
  local insertedRows = {};
  local insertedColumns = {};
  local startRow = 1;
  local startColumn = 1;
  local mainTableWidth = #_table[1];
  local isSubTable = false;

  if (_rows and _insertedRows and _insertedColumns and _mainTableWidth) then

    rows = _rows;
    insertedRows = _insertedRows;
    insertedColumns = _insertedColumns;
    mainTableWidth = _mainTableWidth;
    isSubTable = true;

    local rowNumber = #rows + TableUtils:tableSum(insertedRows);
    local columnNumber = #rows[rowNumber] + 1;

    -- Add the number of inserted rows to the list of inserted rows
    local numberOfInsertedRows = #_table - 1;
    if (insertedRows[rowNumber] == nil or insertedRows[rowNumber] < numberOfInsertedRows) then
      insertedRows[rowNumber] = numberOfInsertedRows;
    end

    -- Add the number of inserted columns to the list of inserted columns
    local numberOfInsertedColumns = #_table[1] - 1;
    if (insertedColumns[columnNumber] == nil) then
      insertedColumns[columnNumber] = {};
    end
    insertedColumns[columnNumber][rowNumber] = numberOfInsertedColumns;

    self:addEmptyColumns(_mainTableWidth, _insertedColumns, rowNumber, columnNumber, numberOfInsertedRows,
                         numberOfInsertedColumns, rows)

    startRow = rowNumber;
    startColumn = columnNumber;

  end

  local rowNumber = startRow

  for y, row in pairs(_table) do

    if (not isSubTable or rows[rowNumber] == nil) then

      rows[rowNumber] = {};

      if (isSubTable) then
        for i = 1, startColumn - 1, 1 do
          rows[rowNumber][i] = "";
        end
      end

    end

    local columnNumber = startColumn;

    for x, field in pairs(_table[y]) do

      if (type(field) == "table") then
        self:convertTable(field, rows, insertedRows, insertedColumns, mainTableWidth);
      else
        rows[rowNumber][columnNumber] = field;

        if (not isSubTable) then
          for i = 1, self:getNumberOfInsertedColumns(insertedColumns, columnNumber), 1 do
            columnNumber = columnNumber + 1;
            rows[rowNumber][columnNumber] = "";
          end
        end

      end
      
      columnNumber = columnNumber + 1;

    end

    rowNumber = rowNumber + 1;

  end

  return rows;

end

---
-- Returns the number of inserted columns for a specific field.
--
-- @tparam int[] _insertedColumns The inserted columns in the format {[x] = {[y] = amountInsertedColumns}}
-- @tparam int _columnNumber The column number
-- @tparam int _rowNumber The row number
--
-- @treturn int The number of inserted columns for the specified field
--
function NestedTableConverter:getNumberOfInsertedColumns(_insertedColumns, _columnNumber, _rowNumber)

  if (_insertedColumns[_columnNumber] == nil or _insertedColumns[_columnNumber][_rowNumber] == nil) then
    return 0;
  else
    return _insertedColumns[_columnNumber][_rowNumber];
  end

end

---
-- Calculates and returns the total table width.
--
-- @tparam int _mainTableWidth The width of the main table
-- @tparam int[] _insertedColumns The inserted columns in the format {[x] = {[y] = amountInsertedColumns}}
--
-- @treturn int The total table width
--
function NestedTableConverter:getTotalTableWidth(_mainTableWidth, _insertedColumns)

  local totalNumberOfInsertedColumns = 0;

  for x, numbersOfInsertedColumns in pairs(_insertedColumns) do
    totalNumberOfInsertedColumns = totalNumberOfInsertedColumns + self:getNumberOfInsertedColumns(_insertedColumns, x);
  end

  return _mainTableWidth + totalNumberOfInsertedColumns;

end

---
-- Returns the maximum number of inserted columns of all rows for a column.
--
-- @tparam int[] _insertedColumns The inserted columns in the format {[x] = {[y] = amountInsertedColumns}}
-- @tparam int _columnNumber The number of the column
--
-- @treturn int The maximum number of inserted columns for this column
--
function NestedTableConverter:getMaximumNumberOfInsertedColumns(_insertedColumns, _columnNumber)

  if (_insertedColumns[_columnNumber] == nil) then
    return 0;
  end

  -- Calculate the maximum number of inserted columns
  local numbersOfInsertedColumns = _insertedColumns[_columnNumber];
  local maximumNumberOfInsertedColumns = 0;

  for y, numberOfInsertedColumns in pairs(numbersOfInsertedColumns) do
    if (numberOfInsertedColumns > maximumNumberOfInsertedColumns) then
      maximumNumberOfInsertedColumns = numberOfInsertedColumns;
    end
  end

  return maximumNumberOfInsertedColumns;

end

---
-- Adds empty columns for all rows above and the current row.
--
-- @tparam int _mainTableWidth The width of the main table
-- @tparam int[] _insertedColumns The inserted columns in the format {[x] = {[y] = amountInsertedColumns}}
-- @tparam int _rowNumber The row number
-- @tparam int _columnNumber The column number
-- @tparam int _numberOfInsertedRows The number of inserted rows
-- @tparam int _numberOfInsertedColumns The number of inserted columns
-- @tparam int _rows The list of rows to which the empty columns will be added
--
function NestedTableConverter:addEmptyColumns(_mainTableWidth, _insertedColumns, _rowNumber,
                                              _columnNumber, _numberOfInsertedRows, _numberOfInsertedColumns,
                                              _rows)

  local tableWidth = self:getTotalTableWidth(_mainTableWidth, _insertedColumns);
  local nextColumnNumber = _columnNumber + _numberOfInsertedColumns;

  for y = 1, _rowNumber, 1 do

    local rowInsertedColumns = self:getNumberOfInsertedColumns(_insertedColumns, _columnNumber, y);

    for x = tableWidth, nextColumnNumber + 1, -1 do
      _rows[y][x] = _rows[y][x - _numberOfInsertedColumns - 1];
    end

    for x = nextColumnNumber - _numberOfInsertedColumns + 1, nextColumnNumber, 1 do
      _rows[y][x] = "";
    end

  end

end


return NestedTableConverter;
