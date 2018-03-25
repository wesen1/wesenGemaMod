---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Output = require("Outputs/Output");
local TableUtils = require("Utils/TableUtils");

---
-- Handles outputs of tables to clients.
--
-- @type TableOutput
--
local TableOutput = {};

-- TableOutput inherits from Output
setmetatable(TableOutput, { __index = Output });


-- Class Methods

---
-- Returns the rows of a table in the format { [1] => [row1 entries], [2] => [row2 Entries], ... }.
-- Merges all sub tables into the main table schema.
--
-- @tparam table _table The table content in the format { [1] => [row1 entries], [2] => [row2 entries], ... }
--
-- @treturn table The table with merged sub tables in the format { [1] => [row1 entries], [2] => [row2 entries], ... }
--
function TableOutput:getRows(_table, _rows, _insertRows, _insertColumns, _mainTableWidth)

  local rows = {};
  local insertRows = {};
  local insertColumns = {};
  local isSubTable = false;
  local startRow = 1;
  local startColumn = 1;
  local mainTableWidth = #_table[1];

  if (_rows and _insertRows and _insertColumns and _mainTableWidth) then
    rows = _rows;
    insertRows = _insertRows;
    insertColumns = _insertColumns;
    mainTableWidth = _mainTableWidth;
    isSubTable = true;

    local rowNumber = #rows + TableUtils:tableSum(insertRows);
    local columnNumber = #rows[rowNumber] + 1;

    local numberOfInsertRows = insertRows[rowNumber];
    if (numberOfInsertRows == nil or numberOfInsertRows < #_table - 1) then
      insertRows[rowNumber] = #_table - 1;
    end

    if (insertColumns[columnNumber] == nil) then
      insertColumns[columnNumber] = {};
    end
    insertColumns[columnNumber][rowNumber] = #_table;

    local tableWidth = self:getTableWidth(_mainTableWidth, insertColumns);

    -- Add empty columns for all rows above and the current row
    for y = 1, rowNumber, 1 do

      local rowInsertColumns = self:getNumberOfInsertColumns(insertColumns, columnNumber, y);

      for x = tableWidth, startColumn + #_table + rowInsertColumns + 1, -1 do
        rows[y][x] = rows[y][x - #_table];
      end

      for x = startColumn + rowInsertColumns + 2, startColumn + #_table + rowInsertColumns + 1, 1 do
        rows[y][x] = "";
      end

    end

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
        self:getRows(field, rows, insertRows, insertColumns, mainTableWidth);
      else
        rows[rowNumber][columnNumber] = field;

        if (not isSubTable) then
          for i = 1, self:getNumberOfInsertColumns(insertColumns, columnNumber), 1 do
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
-- Calculates and returns the total table width.
--
-- @tparam int _mainTableWidth The width of the main table
-- @tparam int[] _insertColumns The insert columns in the format {[x] = {[y] = amountInsertColumns}}
--
-- @treturn int The total table width
--
function TableOutput:getTableWidth(_mainTableWidth, _insertColumns)

  local totalNumberOfInsertColumns = 0;

  for x, numbersOfInsertColumns in pairs(_insertColumns) do
    totalNumberOfInsertColumns = totalNumberOfInsertColumns + self:getNumberOfInsertColumns(_insertColumns, x);
  end

  return _mainTableWidth + totalNumberOfInsertColumns;

end

---
-- Returns the maximum number of insert columns of all columns for a column.
--
-- @tparam int[] _insertColumns The insert columns in the format {[x] = {[y] = amountInsertColumns}}
-- @tparam int _columnNumber The number of the column
--
-- @treturn int The maximum number of insert columns for this column
--
function TableOutput:getMaximumNumberOfInsertColumns(_insertColumns, _columnNumber)

  if (_insertColumns[_columnNumber] == nil) then
    return 0;
  end

  -- Calculate the maximum number of insert columns
  local numbersOfInsertColumns = _insertColumns[_columnNumber];
  local maximumNumberOfInsertColumns = 0;

  for y, numberOfInsertColumns in pairs(numbersOfInsertColumns) do
    if (numberOfInsertColumns > maximumNumberOfInsertColumns) then
      maximumNumberOfInsertColumns = numberOfInsertColumns;
    end
  end
  
  return maximumNumberOfInsertColumns;

end

---
-- Returns the number of insert columns for a specific field.
--
-- @tparam int[] _insertColumns The insert columns in the format {[x] = {[y] = amountInsertColumns}}
-- @tparam int _columnNumber The column number
-- @tparam int _rowNumber The row number
--
-- @treturn int The number of insert columns
--
function TableOutput:getNumberOfInsertColumns(_insertColumns, _columnNumber, _rowNumber)

  if (_insertColumns[_columnNumber] == nil or _insertColumns[_columnNumber][_rowNumber] == nil) then
    return 0;
  else
    return _insertColumns[_columnNumber][_rowNumber];
  end

end

---
-- Prints a table.
--
-- @tparam table _table The columns of a row in the format { [1] => [row1 entries], [2] => [row2 entries], ... }
-- @tparam int _cn The player client number to which the table will be printed
-- @tparam bool _isOneDimensionalTable Indicates whether the table is an one dimensional table
--
function TableOutput:printTable(_table, _cn, _isOneDimensionalTable)

  local rows = _table;
  if (not _isOneDimensionalTable) then
    rows = self:getRows(_table);
  end

  local tableHeight = #rows;
  local tableWidth = #rows[1];
  local widestEntries, entryWidths = self:getWidestEntries(rows);

  for y = 1, tableHeight, 1 do

    local rowString = "";

    for x = 1, tableWidth, 1 do

      local field = rows[y][x];
      local fieldWidth = entryWidths[y][x];

      rowString = rowString .. field;

      if (x < tableWidth) then
        rowString = rowString .. self:getTabs(fieldWidth, widestEntries[x]);
      end

    end

    self:print(rowString, _cn);

  end

end

---
-- Returns the widest entries for every column.
--
-- @tparam table _rows The table with at least two columns and one row
--
-- @treturn table The widest entries per column
-- @treturn table The widths of all entries
--
function TableOutput:getWidestEntries(_rows)

  local widestEntries = {};
  local entryWidths = {};
  local fontDefault = cfg.totable("font_default");
  
  local tableHeight = #_rows;
  local tableWidth = #_rows[1];

  for y = 1, tableHeight, 1 do

    entryWidths[y] = {};
    widestEntries[y] = 0;

    for x = 1, tableWidth - 1, 1 do

      local textWidth = self:getTextWidth(_rows[y][x], fontDefault);

      entryWidths[y][x] = textWidth;

      if (widestEntries[x] == nil or widestEntries[x] < textWidth) then
        widestEntries[x] = textWidth;
      end

    end

  end

  fontDefault = nil;

  return widestEntries, entryWidths;

end

---
-- Calculates and returns the width of text that does not include special characters such as "\n" or "\t".
--
-- @tparam string _text The text
--
-- @treturn int The text width
--
function Output:getTextWidth(_text, _font)

  local textWidth = 0;

  -- exclude "\f_" strings (colors) from width calculation because these characters will not be printed to the screen
  _text = _text:gsub("(%\f[A-Za-z0-9])", "");

  for character in _text:gmatch(".") do
    textWidth = textWidth + self:getCharacterWidth(character, _font);
  end

  return textWidth;

end

---
-- Returns the width of a single character.
--
-- @tparam string _character The character
--
-- @treturn int The character width
--
function Output:getCharacterWidth(_character, _font)

  local width = _font[_character];

  if (width == nil) then
    width = cfg.getvalue("font_default", "default");
  end

  return width;

end

---
-- Returns tabs to format outputs as a table.
--
-- @tparam int _entryLength The length of the entry for which tabs shall be generated
-- @tparam int _longestEntryLength The length of the longest entry that is in the same
--              column like the entry for which tabs are generated
--
-- @treturn string The tabs
--
function Output:getTabs(_entryLength, _longestEntryLength)

  -- Tab width in pixels (1 TabStop = Width of 10 " " or width of 10 default characters
  local tabWidth = 320;

  local numberOfTabs = math.ceil(_longestEntryLength / tabWidth);
  local tabsCovered = math.floor(_entryLength / tabWidth);
  local tabsNeeded = numberOfTabs - tabsCovered;

  return self:generateTabs(tabsNeeded);

end

---
-- Generates a string of tabs.
--
-- @tparam int _amountTabs The amount of tabs
--
-- @treturn string The string of tabs
--
function Output:generateTabs(_amountTabs)

  local tabs = "";

  for i = 1, _amountTabs, 1 do
      tabs = tabs .. "\t";
  end

  return tabs;

end


return TableOutput;
