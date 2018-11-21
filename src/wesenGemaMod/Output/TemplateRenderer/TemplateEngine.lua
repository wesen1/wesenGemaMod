---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local luaRestyTemplateEngine = require("resty.template");

---
-- Provides the template engine to render text templates.
-- The template engine is a customized lua-resty-template template engine.
--
local TemplateEngine = luaRestyTemplateEngine;


---
-- The base path from which template files are loaded.
-- This path assumes that "server.sh" is always started from within the main folder of the lua server.
--
-- @tfield string templateBasePath The path to the base folder for templates
--
TemplateEngine.templateBasePath = lfs.currentdir() .. "/lua/config/templates/";


---
-- Backup the original load function because it will be overridden.
--
TemplateEngine.originalLoadFunction = TemplateEngine.load;

---
-- Loads a template from a specific path.
-- Also adds the path to the templates base folder as a prefix and ".template" as a file ending.
--
-- @tparam string _template The path to the template file relative from the template base folder or a raw template string
--
-- @treturn string The content of the template file
--
function TemplateEngine.load(_template)

  local templateFilePath = TemplateEngine.templateBasePath .. _template  .. ".template";

  local loadedTemplate = TemplateEngine.originalLoadFunction(templateFilePath);
  if (loadedTemplate == templateFilePath) then
    return _template;
  else
    return loadedTemplate;
  end

end


return TemplateEngine;
