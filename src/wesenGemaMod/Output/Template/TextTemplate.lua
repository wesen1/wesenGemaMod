---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseTemplate = require("Output/Template/BaseTemplate");

---
-- Stores necessary information to render a text template.
-- This includes the path to the template file as well as the template values that will be inserted.
--
-- Text templates generate single row strings.
-- Trailing whitespace per line and line endings as well as leading whitespace of the total string are discarded.
--
-- @type TextTemplate
--
local TextTemplate = setmetatable({}, {__index = BaseTemplate});


---
-- TextTemplate constructor.
--
-- @tparam string _templatePath The path to the template file
-- @tparam mixed[] _templateValues The template values to fill the template with
--
-- @treturn TextTemplate The TextTemplate instance
--
function TextTemplate:__construct(_templatePath, _templateValues)

  local instance = BaseTemplate(_templatePath, _templateValues, "TextTemplate");
  setmetatable(instance, {__index = TextTemplate});

  return instance;

end

getmetatable(TextTemplate).__call = TextTemplate.__construct;


return TextTemplate;
