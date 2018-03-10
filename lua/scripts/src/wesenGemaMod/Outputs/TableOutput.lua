---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Output = require("Outputs/Output");

---
-- @type TableOutput Handles outputs of tables to clients.
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
function TableOutput:getRows(_table)

  local table = {};
  local offsetY = 0;
  local longestRow = 0;
  local longestColumn = 0;

  for y, row in pairs (_table) do

    table[y + offsetY] = {};

    for x, field in pairs (row) do

      if (type(field) == "table") then

        local subTable = self:getRows(field);

        for subY, subRow in pairs(subTable) do

          if (table[y + offsetY] == nil) then 
            table[y + offsetY] = {};
          end

          for subX, subField in pairs(subRow) do
            table[y + offsetY][x + subX - 1] = subField;

            if (x + subX - 1 > longestRow) then
              longestRow = x + subX - 1;
            end

          end

          if (subY ~= #subTable) then
            offsetY = offsetY + 1;
          end

        end

      else

        local offsetX = 0;

        while (table[y + offsetY][x + offsetX] ~= nil) do
          offsetX = offsetX + 1;
        end

        table[y + offsetY][x + offsetX] = field;

        if (x + offsetX > longestRow) then
          longestRow = x + offsetX;
        end

      end

    end

    if (y + offsetY > longestColumn) then
      longestColumn = y + offsetY;
    end

  end

  return table, longestRow, longestColumn;

end

---
-- Prints a table.
--
-- @tparam table _table The columns of a row in the format { [1] => [row1 entries], [2] => [row2 entries], ... }
-- @tparam int _cn The player client number to which the table will be printed
--
function TableOutput:printTable(_table, _cn)

  local rows, longestRow, longestColumn = self:getRows(_table);
  local widestEntries, entryWidths = self:getWidestEntries(rows);


  for y = 1, longestColumn, 1 do

    local rowString = "";

    local rowLength = 0;

    for x, field in pairs(rows[y]) do
      if (x > rowLength) then
        rowLength = x;
      end
    end

    for x = 1, longestRow, 1 do

      local field = "";
      local fieldWidth = 0;

      if (rows[y] ~= nil and rows[y][x] ~= nil) then

        field = rows[y][x];
        fieldWidth = entryWidths[y][x];

      end

      rowString = rowString .. field;

      if (x < rowLength) then
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

  for y, row in pairs(_rows) do

    entryWidths[y] = {};
    widestEntries[y] = 0;

    for x, field in pairs(row) do

      local textWidth = self:getTextWidth(field);

      entryWidths[y][x] = textWidth;

      if (widestEntries[x] == nil or widestEntries[x] < textWidth) then
        widestEntries[x] = textWidth;
      end

    end

  end

  return widestEntries, entryWidths;

end

---
-- Calculates and returns the width of text that does not include special characters such as "\n" or "\t".
--
-- @tparam string _text The text
--
-- @treturn int The text width
--
function Output:getTextWidth(_text)

  local textWidth = 0;

  -- exclude "\f_" strings (colors) from width calculation because these characters will not be printed to the screen
  _text = _text:gsub("(%\f[A-Za-z0-9])", "");

  for character in _text:gmatch(".") do
    textWidth = textWidth + self:getCharacterWidth(character);
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
function Output:getCharacterWidth(_character)

  local width = cfg.getvalue("font_default", _character);

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
