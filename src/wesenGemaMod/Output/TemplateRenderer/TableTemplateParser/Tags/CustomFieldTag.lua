---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local RootTag = require("Output/TemplateRenderer/TableTemplateParser/Tags/RootTag");
local RowFieldTag = require("Output/TemplateRenderer/TableTemplateParser/Tags/RowFieldTag");

---
-- Represents a custom field.
-- A custom field is like a inner root tag, tags inside a custom field tag cannot interact with tags that
-- are outside of the custom field
--
-- @type CustomFieldTag
--
local CustomFieldTag = setmetatable({}, {__index = RootTag});


---
-- The list of tag types that are closed by this tag
--
-- @tfield BaseTag[] closeTagTypes
--
CustomFieldTag.closeTagTypes = {RowFieldTag};


---
-- CustomFieldTag constructor.
--
-- @treturn CustomFieldTag The CustomFieldTag instance
--
function CustomFieldTag:__construct()

  local instance = RootTag:__construct();
  setmetatable(instance, {__index = CustomFieldTag});

  return instance;

end

getmetatable(CustomFieldTag).__call = CustomFieldTag.__construct;


---
-- Generates and returns a table from the inner text and tags.
-- Also removes empty columns.
--
-- @treturn table The generated table
--
function CustomFieldTag:generateTable()

  local generatedTable = RootTag.generateTable(self);

  -- Find empty columns
  local columnStates = {};
  for _, tableRow in ipairs(generatedTable) do
    for x, rowField in ipairs(tableRow) do

      local isRowFieldEmpty = (rowField == "");

      -- If no previous state is set or if the state changes from "empty" to "not empty"
      if (columnStates[x] == nil or (not isRowFieldEmpty and columnStates[x] == true)) then
        columnStates[x] = isRowFieldEmpty;
      end

    end
  end

  -- Rebuild the table with only the non empty columns
  local generatedTableWithoutEmptyColumns = {};
  for y, tableRow in ipairs(generatedTable) do

    generatedTableWithoutEmptyColumns[y] = {};
    for x, isColumnEmpty in ipairs(columnStates) do
      if (not isColumnEmpty) then
        table.insert(generatedTableWithoutEmptyColumns[y], tableRow[x]);
      end
    end

  end

  return generatedTableWithoutEmptyColumns;

end


return CustomFieldTag;
