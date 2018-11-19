---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseTemplate = require("Output/Template/BaseTemplate");

---
-- A TableTemplate will be rendered the same way like a text template.
-- When the rendering is done it will be split by the delimiters "-" and "_".
--
-- @type TableTemplate
--
local TableTemplate = setmetatable({}, {__index = BaseTemplate});


---
-- TableTemplate constructor.
--
-- @tparam string _templatePath The path to the template file
-- @tparam mixed[] _templateValues The template values to fill the template with
--
-- @treturn TableTemplate The TextTemplate instance
--
function TableTemplate:__construct(_templatePath, _templateValues)

  local instance = BaseTemplate(_templatePath, _templateValues, "TableTemplate");
  setmetatable(instance, {__index = TableTemplate});

  return instance;

end

getmetatable(TableTemplate).__call = TableTemplate.__construct;


return TableTemplate;
