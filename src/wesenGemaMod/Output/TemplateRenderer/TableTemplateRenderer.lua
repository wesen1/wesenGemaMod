---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ClientOutputFactory = require("Output/ClientOutput/ClientOutputFactory");
local TableTemplateParser = require("Output/TemplateRenderer/TableTemplateParser/TableTemplateParser");

---
-- Renders table templates.
--
-- @type TableTemplateRenderer
--
local TableTemplateRenderer = setmetatable({}, {});


---
-- The table template parser
--
-- @tfield TableTemplateParser tableTemplateParser
--
TableTemplateRenderer.tableTemplateParser = nil;


---
-- TableTemplateRenderer constructor.
--
-- @treturn TableTemplateRenderer The TableTemplateRenderer instance
--
function TableTemplateRenderer:__construct()

  local instance = setmetatable({}, {__index = TableTemplateRenderer});

  instance.tableTemplateParser = TableTemplateParser();

  return instance;

end

getmetatable(TableTemplateRenderer).__call = TableTemplateRenderer.__construct;


---
-- Renders a table template and returns the generated table.
-- The generated table follows this structure:
--
-- {
--  -- Row
--  [1] =
--  {
--    -- Row Field
--    [1] = {
--
--      -- Sub Row
--      [1] = {
--
--        -- Sub Row Field
--        [1] = "text"
--
--        -- And so on
--      }
--    }
--  }
-- }
--
-- @tparam TextTemplateRenderer The text template renderer
-- @tparam TableTemplate The table template
--
-- @treturn string[] The generated row output strings
--
function TableTemplateRenderer:getClientOutputTable(_textTemplateRenderer, _tableTemplate)

  local renderedTemplate = _textTemplateRenderer:renderTemplate(_tableTemplate);
  local generatedTable = self.tableTemplateParser:parseRenderedTemplate(renderedTemplate);

  return ClientOutputFactory.getClientOutputTable(generatedTable)

end


return TableTemplateRenderer
