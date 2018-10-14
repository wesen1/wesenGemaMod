---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local NestedTableConverter = require("Output/Util/NestedTableConverter");
local TextWidthCalculator = require("Output/Util/TextWidthCalculator");

---
-- Generates row output strings from tables.
-- @todo Fix this and NestedTableConverter ...
--
-- @type TableRenderer
--
local TableRenderer = setmetatable({}, {});


---
-- The text width calculator
--
-- @tfield TextWidthCalculator textWidthCalculator
--
TableRenderer.textWidthCalculator = nil;


---
-- TableRenderer constructor.
--
function TableRenderer:__construct()

  local instance = setmetatable({}, { __index = TableRenderer });

  instance.textWidthCalculator = TextWidthCalculator("font_default", true);
  
  return instance;

end

getmetatable(TableRenderer).__call = TableRenderer.__construct;



-- Class Methods

---
-- Returns the row output strings of a table.
--
-- @tparam table _table The columns of a row in the format { [1] => [row1 entries], [2] => [row2 entries], ... }
-- @tparam bool _isOneDimensionalTable Indicates whether the table is an one dimensional table
--
-- @treturn String[] The row output strings
--
function TableRenderer:getRowOutputStrings(_table, _isOneDimensionalTable)

  local rows = _table;
  if (not _isOneDimensionalTable) then
    rows = NestedTableConverter:convertTable(_table);
  end

  local tableHeight = #rows;
  local tableWidth = #rows[1];
  local widestEntries, entryWidths = self:getWidestEntries(rows);
  local rowStrings = {};

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

    rowStrings[y] = rowString;

  end

  return rowStrings;

end

---
-- Returns the widest entries for every column.
--
-- @tparam table _rows The table with at least two columns and one row
--
-- @treturn table The widest entries per column
-- @treturn table The widths of all entries
--
function TableRenderer:getWidestEntries(_rows)

  local widestEntries = {};
  local entryWidths = {};

  local tableHeight = #_rows;
  local tableWidth = #_rows[1];

  for y = 1, tableHeight, 1 do

    entryWidths[y] = {};

    for x = 1, tableWidth - 1, 1 do

      local textWidth = self.textWidthCalculator:getTextWidth(_rows[y][x]);

      entryWidths[y][x] = textWidth;

      if (widestEntries[x] == nil or widestEntries[x] < textWidth) then
        widestEntries[x] = textWidth;
      end

    end

  end

  return widestEntries, entryWidths;

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
function TableRenderer:getTabs(_entryLength, _longestEntryLength)

  local emptySpaceCharacterWidth = self.textWidthCalculator:getCharacterWidth(" ");

  -- Tab width in pixels (1 TabStop seems to be 10 x " " + 1 pixel)
  local tabWidth = emptySpaceCharacterWidth * 10 + 1;

  local numberOfTabs = math.ceil(_longestEntryLength / tabWidth);
  local tabsCovered = math.floor(_entryLength / tabWidth);
  local tabsNeeded = numberOfTabs - tabsCovered;

  -- If the entry length is 0 pixels away from a tab stop
  -- one tab will have no effect, therefore an additional tab is added
  if (_entryLength - tabsCovered * tabWidth == 0) then
    tabsNeeded = tabsNeeded + 1;
  end

  return string.rep("\t", tabsNeeded);

end


return TableRenderer;
