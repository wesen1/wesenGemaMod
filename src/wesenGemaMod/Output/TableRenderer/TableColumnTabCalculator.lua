---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TabStopCalculator = require("Output/TableRenderer/TabStopCalculator");
local TextWidthCalculator = require("Output/TableRenderer/TextWidthCalculator/TextWidthCalculator");

---
-- Calculates the required tabs for table columns.
--
-- @type TableColumnTabCalculator
--
local TableColumnTabCalculator = setmetatable({}, {});


---
-- The tab stop calculator
--
-- @tfield TabStopCalculator tabStopCalculator
--
TableColumnTabCalculator.tabStopCalculator = nil;

---
-- The text width calculator
--
-- @tfield TextWidthCalculator textWidthCalculator
--
TableColumnTabCalculator.textWidthCalculator = nil;


---
-- TableColumnTabCalculator constructor.
--
-- @treturn TableColumnTabCalculator The TableColumnCreator instance
--
function TableColumnTabCalculator:__construct()

  local instance = setmetatable({}, {__index = TableColumnTabCalculator});

  instance.textWidthCalculator = TextWidthCalculator("font_default", true);

  local tabWidth = instance.textWidthCalculator:getCharacterWidth("\t");
  instance.tabStopCalculator = TabStopCalculator(tabWidth);

  return instance;

end

getmetatable(TableColumnTabCalculator).__call = TableColumnTabCalculator.__construct;


-- Public Methods

---
-- Calculates and returns the tabs for a table column.
--
-- @tparam string[] _table The table
-- @tparam int _columnId The column id
--
-- @treturn The table column tabs in the format { [rowId] = "tabs" }
--
function TableColumnTabCalculator:calculateTabsForTableColumn(_table, _columnId)

  -- Get the entry widths for the column
  local tableColumnFieldWidths = self:getTableColumnFieldWidths(_table, _columnId);

  -- Find the highest column field width
  local highestColumnFieldWidth = 0;
  for _, tableColumnFieldWidth in ipairs(tableColumnFieldWidths) do
    if (tableColumnFieldWidth > highestColumnFieldWidth) then
      highestColumnFieldWidth = tableColumnFieldWidth;
    end
  end

  -- Calculate the target tab stop position
  local targetTabStopPosition = self.tabStopCalculator:getLastPassedTabStopPosition(highestColumnFieldWidth);

  return self:getTabsForColumn(tableColumnFieldWidths, targetTabStopPosition);

end


-- Private Methods

---
-- Returns the widths for all fields of a table column.
--
-- @tparam string[][] _table The table
-- @tparam int _columnId The column id
--
-- @treturn int[] The column field widths
--
function TableColumnTabCalculator:getTableColumnFieldWidths(_table, _columnId)

  local columnEntryWidths = {};
  for y, tableRow in ipairs(_table) do

    local fieldWidth = 0;
    if (tableRow[_columnId]) then
      fieldWidth = self.textWidthCalculator:getTextWidth(tableRow[_columnId]);
    end

    columnEntryWidths[y] = fieldWidth;
  end

  return columnEntryWidths;

end

---
-- Returns the necessary pad tabs for a column field.
--
-- @tparam int _fieldWidth The width of the column field
-- @tparam int _targetTabStopPosition The position of the target tab stop
--
-- @treturn string The pad tabs for the column field
--
function TableColumnTabCalculator:getTabsForField(_fieldWidth, _targetTabStopPosition)

  local tabsNeeded = self.tabStopCalculator:getNumberOfTabsToTabStop(_fieldWidth, _targetTabStopPosition);

  return string.rep("\t", tabsNeeded);

end

---
-- Returns the pad tabs for each field of the table column.
--
-- @tparam int[] _fieldWidths The column field widths
-- @tparam int _targetTabStopPosition The position of the target tab stop
--
-- @treturn string[] The pad tabs for all table column fields
--
function TableColumnTabCalculator:getTabsForColumn(_fieldWidths, _targetTabStopPosition)

  local columnTabs = {};
  for y, fieldWidth in ipairs(_fieldWidths) do
    columnTabs[y] = self:getTabsForField(fieldWidth, _targetTabStopPosition);
  end

  return columnTabs;

end


return TableColumnTabCalculator;
