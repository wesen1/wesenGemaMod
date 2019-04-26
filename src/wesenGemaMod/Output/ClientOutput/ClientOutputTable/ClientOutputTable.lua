---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT

local BaseClientOutput = require("Output/ClientOutput/BaseClientOutput")
local ClientOutputTableRenderer = require("Output/ClientOutput/ClientOutputTable/ClientOutputTableRenderer")

---
-- Represents a output table for the console in the players games.
--
-- @type ClientOutputTable
--
local ClientOutputTable = setmetatable({}, {__index = BaseClientOutput})


---
-- The rows inside this table that were parsed from a lua table
--
-- @tfield table[] rows
--
ClientOutputTable.rows = nil

---
-- The renderer for this ClientOutputTable
--
-- @tfield ClientOutputTableRenderer renderer
--
ClientOutputTable.renderer = nil

---
-- The output configuration for specific groups of the table (rows, columns and fields)
--
-- @tfield mixed[][] groupConfigurations
--
ClientOutputTable.groupConfigurations = nil


---
-- ClientOutputTable constructor.
--
-- @tparam SymbolWidthLoader _symbolWidthLoader The symbol width loader
-- @tparam TabStopCalculator _tabStopCalculator The tab stop calculator
-- @tparam int _maximumLineWidth The maximum line width
--
-- @treturn ClientOutputTable The ClientOutputTable instance
--
function ClientOutputTable:__construct(_symbolWidthLoader, _tabStopCalculator, _maximumLineWidth)

  local instance = BaseClientOutput(_symbolWidthLoader, _tabStopCalculator, _maximumLineWidth)
  setmetatable(instance, {__index = ClientOutputTable})

  instance.renderer = ClientOutputTableRenderer(instance)

  return instance

end

getmetatable(ClientOutputTable).__call = ClientOutputTable.__construct


-- Getters and Setters

---
-- Returns the rows of this ClientOutputTable.
--
-- @treturn table[] The rows
--
function ClientOutputTable:getRows()
  return self.rows
end


-- Public Methods

---
-- Configures this ClientOutputTable.
--
-- @tparam table _configuration The configuration
--
function ClientOutputTable:configure(_configuration)

  BaseClientOutput.configure(self, _configuration)

  -- Parse the column, row and field configs
  self.groupConfigurations = {}
  if (_configuration["rows"]) then
    self.groupConfigurations["rows"] = _configuration["rows"]
  end

  if (_configuration["columns"]) then
    self.groupConfigurations["columns"] = _configuration["columns"]
  end

  if (_configuration["fields"]) then
    self.groupConfigurations["fields"] = _configuration["fields"]
  end

end

---
-- Parses a table.
-- The table must be in the format { [y] = { rowFields } }, while a row field may contain a sub table.
-- Every row must have the same number of columns.
--
-- @tparam table _table The table to parse
--
function ClientOutputTable:parse(_table)

  local ClientOutputFactory = require("Output/ClientOutput/ClientOutputFactory")

  self.rows = {}
  for y, row in ipairs(_table) do

    self.rows[y] = {}

    if (type(row) ~= "table") then
      self.rows[y][1] = ClientOutputFactory.getInstance():getClientOutputString(row)
      self.rows[y][1]:configure(self:getConfigurationForField(y, 1))
    else

      for x, field in ipairs(row) do

        if (type(field) == "table") then
          self.rows[y][x] = ClientOutputFactory.getInstance():getClientOutputTable(field)
        else
          self.rows[y][x] = ClientOutputFactory.getInstance():getClientOutputString(field)
        end

        self.rows[y][x]:configure(self:getConfigurationForField(y, x))

      end

    end
  end

end

---
-- Returns the number of tabs that this client output's content requires.
--
-- @treturn int The number of required tabs
--
function ClientOutputTable:getNumberOfRequiredTabs()

  local numberOfRequiredTabs = 0
  for x = 1, self:getNumberOfColumns(), 1 do
    numberOfRequiredTabs = numberOfRequiredTabs + self:getNumberOfRequiredTabsForColumn(x)
  end

  return numberOfRequiredTabs

end

---
-- Returns the minimum number of tabs that this client output's content requires.
--
-- @treturn int The minimum number of required tabs
--
function ClientOutputTable:getMinimumNumberOfRequiredTabs()

  local minimumNumberOfRequiredTabs = 0
  for x = 1, self:getNumberOfColumns(), 1 do
    minimumNumberOfRequiredTabs = minimumNumberOfRequiredTabs + self:getMinimumNumberOfRequiredTabsForColumn(x)
  end

  return minimumNumberOfRequiredTabs

end

---
-- Returns the output rows to display this client output's contents.
--
-- @treturn string[] The output rows
--
function ClientOutputTable:getOutputRows()
  return self.renderer:getOutputRows()
end

---
-- Returns the output rows to display this client output's contents wrapped in ClientOutputString's.
--
-- @treturn ClientOutputString[] The output rows
--
function ClientOutputTable:getOutputRowsAsClientOutputStrings()
  return self.renderer:getOutputRows(true)
end


---
-- Returns the required number of tabs for a specific column.
--
-- @tparam int _columnNumber The column number
--
-- @treturn int The required number of tabs for the column
--
function ClientOutputTable:getNumberOfRequiredTabsForColumn(_columnNumber)

  if (_columnNumber > self:getNumberOfColumns()) then
    return 0
  end

  local numberOfRequiredTabs = 0
  for y, row in ipairs(self.rows) do

    local numberOfRequiredTabsForField = row[_columnNumber]:getNumberOfRequiredTabs()
    if (numberOfRequiredTabsForField > numberOfRequiredTabs) then
      numberOfRequiredTabs = numberOfRequiredTabsForField
    end

  end

  return numberOfRequiredTabs

end

---
-- Returns the minimun required number tabs for a specific column.
--
-- @tparam int _columnNumber The column number
--
-- @treturn int The minimum required number of tabs for the column
--
function ClientOutputTable:getMinimumNumberOfRequiredTabsForColumn(_columnNumber)

  if (_columnNumber > self:getNumberOfColumns()) then
    return 0
  end

  local minimumNumberOfRequiredTabs = 0
  for y, row in ipairs(self.rows) do

    local minimumNumberOfRequiredTabsForField = row[_columnNumber]:getMinimumNumberOfRequiredTabs()
    if (minimumNumberOfRequiredTabsForField > minimumNumberOfRequiredTabs) then
      minimumNumberOfRequiredTabs = minimumNumberOfRequiredTabsForField
    end

  end

  return minimumNumberOfRequiredTabs

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


-- Private Methods

---
-- Returns the client output configuration for a specific table field.
--
-- @tparam int _y The y coordinate of the field
-- @tparam int _x The x coordinate of the field
--
-- @treturn table The client output configuration for the field
--
function ClientOutputTable:getConfigurationForField(_y, _x)

  -- Create a configuration with this ClientOutputTable's own configuration
  local configuration = {
    newLineIndent = self.newLineIndent,
    lineSplitCharacters = self.lineSplitCharacters
  }

  -- Check group configurations
  local allowedGroupValueNames = { "newLineIndent", "lineSplitCharacters" }

  if (self.groupConfigurations["rows"] and self.groupConfigurations["rows"][_y]) then
    self:addGroupConfiguration(
      configuration, self.groupConfigurations["rows"][_y], allowedGroupValueNames
    )
  end

  if (self.groupConfigurations["columns"] and self.groupConfigurations["columns"][_x]) then
    self:addGroupConfiguration(
      configuration, self.groupConfigurations["columns"][_x], allowedGroupValueNames
    )
  end

  if (self.groupConfigurations["fields"] and
      self.groupConfigurations["fields"][_y] and self.groupConfigurations["fields"][_y][_x]
  ) then
    self:addGroupConfiguration(
      configuration, self.groupConfigurations["fields"][_y][_x], allowedGroupValueNames
    )
  end

  return configuration

end

---
-- Adds the values of a group configuration to a configuration object.
--
-- @tparam table _configuration The configuration object
-- @tparam table _groupConfiguration The group configuration
-- @tparam string[] _valueNames The names of the values to copy into the configuration object
--
function ClientOutputTable:addGroupConfiguration(_configuration, _groupConfiguration, _valueNames)

  for _, valueName in ipairs(_valueNames) do
    if (_groupConfiguration[valueName] ~= nil) then
      _configuration[valueName] = _groupConfiguration[valueName]
    end
  end

end


return ClientOutputTable
