---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local NestedTableConverter = require("Outputs/Helpers/NestedTableConverter");
local Output = require("Outputs/Output");

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
-- Prints a table.
--
-- @tparam table _table The columns of a row in the format { [1] => [row1 entries], [2] => [row2 entries], ... }
-- @tparam int _cn The player client number to which the table will be printed
-- @tparam bool _isOneDimensionalTable Indicates whether the table is an one dimensional table
--
function TableOutput:printTable(_table, _cn, _isOneDimensionalTable)

  local rows = _table;
  if (not _isOneDimensionalTable) then
    rows = NestedTableConverter:convertTable(_table);
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
-- @tparam int[] The font pixel widths in the format {[character] = width}
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
-- @tparam int[] The font pixel widths in the format {[character] = width}
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
