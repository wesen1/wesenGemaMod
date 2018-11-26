---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TableColumnTabCalculator = require("Output/TableRenderer/TableColumnTabCalculator");

---
-- Returns the output rows for a table.
--
-- @type TableRenderer
--
local TableRenderer = setmetatable({}, {});


---
-- The table column tab calculator
--
-- @tfield TableColumnTabCalculator tableColumnTabCalculator
--
TableRenderer.tableColumnTabCalculator = nil;


---
-- TableRenderer constructor.
--
-- @treturn TableRenderer The TableRenderer instance
--
function TableRenderer:__construct()

  local instance = setmetatable({}, {__index = TableRenderer});

  instance.tableColumnTabCalculator = TableColumnTabCalculator();

  return instance;

end

getmetatable(TableRenderer).__call = TableRenderer.__construct;


---
-- Returns the row output strings for a table.
-- The tables must be in the format { [y] = { rowFields } }, while a row field may contain a sub table.
--
-- @tparam table _outputTable The output table
--
-- @treturn string[] The row output strings
--
function TableRenderer:getRowOutputStrings(_outputTable)

  local outputTable = _outputTable;

  -- Replace the sub tables with the result of getRowOuputStrings()
  outputTable = self:convertFieldTablesToRows(outputTable);

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
-- Replaces sub tables by the row output strings of the sub table.
--
-- @tparam table _outputTable The output table
--
-- @treturn table The table with converted sub tables
--
function TableRenderer:convertFieldTablesToRows(_outputTable)

  local outputTable = {};

  for y, tableRow in ipairs(_outputTable) do

    outputTable[y] = {};
    for x, tableField in ipairs(tableRow) do
      if (type(tableField) == "table") then
        outputTable[y][x] = self:getRowOutputStrings(tableField);
      else
        outputTable[y][x] = tableField;
      end
    end

  end

  return outputTable;

end

---
-- Combines the rows of the sub tables with the total table.
--
-- @tparam table _outputTable The output table with converted sub tables
--
-- @treturn string[][] The table with combined sub table rows
--
function TableRenderer:mergeSubRows(_outputTable)

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
function TableRenderer:addTabsToFields(_outputTable)

  local outputTable = {};

  if (_outputTable) then

    outputTable = _outputTable;
    local numberOfColumns = #outputTable[1];

    for x = 1, numberOfColumns - 1, 1 do

      local columnTabs = self.tableColumnTabCalculator:calculateTabsForTableColumn(outputTable, x);

      for y, tableRow in ipairs(outputTable) do

        local field = "";
        if (outputTable[y][x]) then
          field = outputTable[y][x];
        end

        outputTable[y][x] = field .. columnTabs[y];
      end

    end

  end

  return outputTable;

end


return TableRenderer;
