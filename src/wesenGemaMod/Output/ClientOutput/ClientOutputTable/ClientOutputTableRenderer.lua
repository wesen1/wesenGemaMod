---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ClientOutputString = require("Output/ClientOutput/ClientOutputString/ClientOutputString")
local ObjectUtils = require("Util/ObjectUtils")

---
-- Returns the output rows for a ClientOutputTable.
--
-- @type ClientOutputTableRenderer
--
local ClientOutputTableRenderer = setmetatable({}, {})


---
-- The symbol width loader
--
-- @tfield SymbolWidthLoader symbolWidthLoader
--
ClientOutputTableRenderer.symbolWidthLoader = nil

---
-- The tab stop calculator
--
-- @tfield TabStopCalculator tabStopCalculator
--
ClientOutputTableRenderer.tabStopCalculator = nil


---
-- ClientOutputTableRenderer constructor.
--
-- @tparam SymbolWidthLoader _symbolWidthLoader The symbol width loader for generated ClientOutputString's
-- @tparam TabStopCalculator _tabStopCalculator The tab stop calculator
--
-- @treturn ClientOutputTableRenderer The ClientOutputTableRenderer instance
--
function ClientOutputTableRenderer:__construct(_symbolWidthLoader, _tabStopCalculator)

  local instance = setmetatable({}, {__index = ClientOutputTableRenderer})

  instance.symbolWidthLoader = _symbolWidthLoader
  instance.tabStopCalculator = _tabStopCalculator

  return instance

end

getmetatable(ClientOutputTableRenderer).__call = ClientOutputTableRenderer.__construct


---
-- Returns the row output strings for a ClientOutputTable.
--
-- @tparam ClientOutputTable _clientOutputTable The ClientOutputTable
-- @tparam int _numberOfAvailableTabs The number of available tabs for the output
-- @tparam bool _splitStringsAtWhitespace Whether to split strings at whitespaces
--
-- @treturn string[] The row output strings
--
function ClientOutputTableRenderer:getRowStrings(_clientOutputTable, _numberOfAvailableTabs, _splitStringsAtWhitespace)

  self.clientOutputTable = _clientOutputTable

  self:calculateNumbersOfTabsPerColumn(_numberOfAvailableTabs)

  -- Replace the sub tables with the result of getRowStrings()
  local outputTable = self:convertSubTablesToRows(_splitStringsAtWhitespace);

  -- Merge the sub rows into the main table
  outputTable = self:mergeSubRows(outputTable);

  -- Add the tabs to the fields
  outputTable = self:addTabsToFields(outputTable);

  -- Build the row output strings by joining the fields together with "\t"s
  local rowOutputStrings = {};
  for y, tableRow in ipairs(outputTable) do
    rowOutputStrings[y] = table.concat(tableRow, "\t");
  end

  return rowOutputStrings;

end


-- Private Methods

---
-- Calculates the numbers of tabs to use per column.
-- The result is saved in the numbersOfTabsPerColumn attribute.
--
-- @tparam int _numberOfAvailableTabs The number of available tabs for the output
--
function ClientOutputTableRenderer:calculateNumbersOfTabsPerColumn(_numberOfAvailableTabs)

  local numberOfColumns = self.clientOutputTable:getNumberOfColumns()

  self.numbersOfTabsPerColumn = {}
  for x = 1, numberOfColumns, 1 do
    self.numbersOfTabsPerColumn[x] = self.clientOutputTable:getNumberOfRequiredTabsForColumn(x)
  end

  local remainingNumberOfAvailableTabs = _numberOfAvailableTabs - self.clientOutputTable:getTotalNumberOfRequiredTabs()

  if (remainingNumberOfAvailableTabs < 0) then

    local minimumNumbersOfTabsPerColumn = {}
    for x = 1, numberOfColumns, 1 do
      minimumNumbersOfTabsPerColumn[x] = self.clientOutputTable:getNumberOfRequiredTabsForColumn(x, true)
    end

    while (remainingNumberOfAvailableTabs < 0) do

      -- Find the column with the biggest distance to the minimum number of required tabs
      local shrinkColumnNumber
      local maximumNumberOfRemovableTabs = 0
      for x = 1, numberOfColumns, 1 do

        local numberOfRemovableTabs = self.numbersOfTabsPerColumn[x] - minimumNumbersOfTabsPerColumn[x]
        if (numberOfRemovableTabs > maximumNumberOfRemovableTabs) then
          maximumNumberOfRemovableTabs = numberOfRemovableTabs
          shrinkColumnNumber = x
        end

      end

      if (shrinkColumnNumber == nil) then
        break
      else
        self.numbersOfTabsPerColumn[shrinkColumnNumber] = self.numbersOfTabsPerColumn[shrinkColumnNumber] - 1
        remainingNumberOfAvailableTabs = remainingNumberOfAvailableTabs + 1
      end

    end

  end

end

---
-- Replaces sub tables by the row output strings of the sub table.
--
-- @tparam bool _splitStringsAtWhitespace Whether to split strings at whitespaces
--
-- @treturn table The table with converted sub tables
--
function ClientOutputTableRenderer:convertSubTablesToRows(_splitStringsAtWhitespace)

  local outputTable = {};

  for y, tableRow in ipairs(self.clientOutputTable:getRows()) do

    outputTable[y] = {};
    for x, tableField in ipairs(tableRow) do

      local numberOfAvailableTabs = self.numbersOfTabsPerColumn[x]

      if (ObjectUtils:isInstanceOf(tableField, ClientOutputString)) then
        local tabPixelPosition = self.tabStopCalculator:convertTabNumberToPosition(numberOfAvailableTabs)
        outputTable[y][x] = tableField:splitIntoIntoPixelGroups(tabPixelPosition, _splitStringsAtWhitespace)
      else
        outputTable[y][x] = tableField:getRowStringsByTabNumber(numberOfAvailableTabs, _splitStringsAtWhitespace)
      end
    end

  end

  return outputTable

end

---
-- Combines the rows of the sub tables with the total table.
--
-- @tparam table _outputTable The output table with converted sub tables
--
-- @treturn string[][] The table with combined sub table rows
--
function ClientOutputTableRenderer:mergeSubRows(_outputTable)

  local outputTable = {};
  local mainTableInsertIndex = 1;

  for y, tableRow in ipairs(_outputTable) do

    outputTable[mainTableInsertIndex] = {};

    local maximumMainTableInsertIndexForTable = mainTableInsertIndex;
    for x, tableField in ipairs(tableRow) do

      if (type(tableField) == "table") then
        -- The field contains sub rows
        local mainTableInsertIndexForTable = mainTableInsertIndex;
        local isFirstSubRow = true;

        for subY, subRow in ipairs(tableField) do

          if (isFirstSubRow) then
            isFirstSubRow = false;
          else
            mainTableInsertIndexForTable = mainTableInsertIndexForTable + 1;
          end

          -- Create the additional row if it doesn't exist
          if (not outputTable[mainTableInsertIndexForTable]) then
            outputTable[mainTableInsertIndexForTable] = {};
          end

          outputTable[mainTableInsertIndexForTable][x] = subRow;

          if (mainTableInsertIndexForTable > maximumMainTableInsertIndexForTable) then
            maximumMainTableInsertIndexForTable = mainTableInsertIndexForTable;
          end

        end

      else
        outputTable[mainTableInsertIndex][x] = tableField;
      end

    end

    mainTableInsertIndex = maximumMainTableInsertIndexForTable + 1;

  end

  return outputTable;

end

---
-- Adds the tabs to all fields of the table.
--
-- @tparam table _outputTable The output table
--
-- @treturn table The output table with added tabs
--
function ClientOutputTableRenderer:addTabsToFields(_outputTable)

  local outputTable = {};

  if (_outputTable) then

    outputTable = _outputTable;

    local numberOfColumns = #outputTable[1];
    for x = 1, numberOfColumns - 1, 1 do
      for y, tableRow in ipairs(outputTable) do

        local field = outputTable[y][x]
        if (field == nil) then
          field = ClientOutputString(self.symbolWidthLoader, "")
        elseif (not ObjectUtils:isInstanceOf(field, ClientOutputString)) then
          field = ClientOutputString(self.symbolWidthLoader, field)
        end

        field:padUntilTabStopNumber(self.numbersOfTabsPerColumn[x] - 1)
        outputTable[y][x] = field:toString()

      end
    end

  end

  return outputTable

end


return ClientOutputTableRenderer
