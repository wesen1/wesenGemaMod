---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT

local ClientOutputString = require("Output/ClientOutput/ClientOutputString/ClientOutputString")
local ClientOutputTableRenderer = require("Output/ClientOutput/ClientOutputTable/ClientOutputTableRenderer")
local ObjectUtils = require("Util/ObjectUtils")
local TabStopCalculator = require("Output/ClientOutput/Util/TabStopCalculator")

---
-- Represents a output table for the console in the players games.
--
-- @type ClientOutputTable
--
local ClientOutputTable = setmetatable({}, {})


---
-- The symbol width loader
--
-- @tfield SymbolWidthLoader symbolWidthLoader
--
ClientOutputTable.symbolWidthLoader = nil

---
-- The tab stop calculator
--
-- @tfield TabStopCalculator tabStopCalculator
--
ClientOutputTable.tabStopCalculator = nil

---
-- The rows inside this table that were parsed from a lua table
--
-- @tfield table[] rows
--
ClientOutputTable.rows = nil


---
-- ClientOutputTable constructor.
--
-- @tparam SymbolWidthLoader _symbolWidthLoader The symbol width loader
--
-- @treturn ClientOutputTable The ClientOutputTable instance
--
function ClientOutputTable:__construct(_symbolWidthLoader)
  local instance = setmetatable({}, {__index = ClientOutputTable})

  instance.symbolWidthLoader = _symbolWidthLoader
  instance.tabStopCalculator = TabStopCalculator(instance.symbolWidthLoader:getCharacterWidth("\t"))

  return instance
end

getmetatable(ClientOutputTable).__call = ClientOutputTable.__construct


---
-- Static method that creates and returns a ClientOutputTable instance from a table.
--
-- @tparam SymbolWidthLoader _symbolWidthLoader The symbol width loader
-- @tparam table _table The table to parse
--
-- @treturn ClientOutputTable The ClientOutputTable instance
--
function ClientOutputTable.createFromTable(_symbolWidthLoader, _table)
  local instance = ClientOutputTable(_symbolWidthLoader)
  instance:parse(_table)

  return instance
end


-- Getters and Setters

---
-- Returns the rows of this ClientOutputTable.
--
-- @treturn table[] The rows
--
function ClientOutputTable:getRows()
  return self.rows
end

---
-- Parses a table.
-- The table must be in the format { [y] = { rowFields } }, while a row field may contain a sub table.
-- Every row must have the same number of columns.
--
-- @tparam table _table The table to parse
--
function ClientOutputTable:parse(_table)

  self.rows = {}

  for y, row in ipairs(_table) do

    self.rows[y] = {}

    if (type(row) ~= "table") then
      self.rows[y][1] = ClientOutputString(self.symbolWidthLoader, row)
    else

      for x, field in ipairs(row) do

        if (type(field) == "table") then
          self.rows[y][x] = ClientOutputTable.createFromTable(self.symbolWidthLoader, field)
        else
          self.rows[y][x] = ClientOutputString(self.symbolWidthLoader, field)
        end

      end

    end
  end

end

---
-- Returns the row strings for this ClientOutputTable by using a specific line width.
--
-- @tparam int _maximumOutputLineWidth The maximum output line width in 3x pixels
-- @tparam bool _splitStringsAtWhitespace Whether to split strings at whitespace
--
-- @treturn string[] The row strings
--
function ClientOutputTable:getRowStringsByLineWidth(_maximumOutputLineWidth, _splitStringsAtWhitespace)

  local numberOfAvailableTabs = self.tabStopCalculator:getNumberOfPassedTabStops(_maximumOutputLineWidth)
  return self:getRowStringsByTabNumber(numberOfAvailableTabs, _splitStringsAtWhitespace)

end

---
-- Returns the row strings for this ClientOutputTable by using a specific maximum tab number.
--
-- @tparam int _tabNumber The maximum tab number
-- @tparam bool _splitStringsAtWhitespace Whether to split strings at whitespace
--
-- @treturn string[] The row strings
--
function ClientOutputTable:getRowStringsByTabNumber(_tabNumber, _splitStringsAtWhitespace)

  local renderer = ClientOutputTableRenderer(self.symbolWidthLoader, self.tabStopCalculator)
  return renderer:getRowStrings(self, _tabNumber, _splitStringsAtWhitespace)

end

---
-- Returns the required number of tabs for a specific column.
--
-- @tparam int _columnNumber The column number
-- @tparam bool _getMinimumNumber Whether to return the minimum number or the number needed to fit the content
--
-- @treturn int The required number of tabs for the column
--
function ClientOutputTable:getNumberOfRequiredTabsForColumn(_columnNumber, _getMinimumNumber)

  if (_columnNumber > self:getNumberOfColumns()) then
    return 0
  end

  local maximumNumberOfRequiredTabs = 0
  for y, row in ipairs(self.rows) do

    local field = row[_columnNumber]

    local numberOfRequiredTabsForField
    if (ObjectUtils:isInstanceOf(field, ClientOutputTable)) then
      numberOfRequiredTabsForField = field:getTotalNumberOfRequiredTabs(_getMinimumNumber)
    else

      if (_getMinimumNumber) then
        numberOfRequiredTabsForField = 1
      else
        numberOfRequiredTabsForField = field:getNumberOfPassedTabStops() + 1
      end
    end

    if (numberOfRequiredTabsForField > maximumNumberOfRequiredTabs) then
      maximumNumberOfRequiredTabs = numberOfRequiredTabsForField
    end

  end

  return maximumNumberOfRequiredTabs

end

---
-- Returns the required number of tabs for the entire table.
--
-- @tparam bool _getMinimumNumber Whether to return the minimum number or the number needed to fit the content
--
-- @treturn int The required number of tabs for the entire table
--
function ClientOutputTable:getTotalNumberOfRequiredTabs(_getMinimumNumber)

  local numberOfColumns = self:getNumberOfColumns()
  if (numberOfColumns == 0) then
    return 0
  end

  local totalNumberOfRequiredTabs = 0
  for x = 1, numberOfColumns, 1 do
    totalNumberOfRequiredTabs = totalNumberOfRequiredTabs + self:getNumberOfRequiredTabsForColumn(x, _getMinimumNumber)
  end

  return totalNumberOfRequiredTabs

end

---
-- Returns the number of columns in this table.
--
-- @treturn int The number of columns in this table
--
function ClientOutputTable:getNumberOfColumns()

  if (#self.rows == 0) then
    return 0
  else
    return #self.rows[1]
  end

end


return ClientOutputTable
