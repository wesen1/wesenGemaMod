---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require("Util/Exception")
local TemplateFactory = require("Output/Template/TemplateFactory")

---
-- Exception that uses a template to render its message.
--
-- @type TemplateException
--
local TemplateException = setmetatable({}, {__index = Exception})


---
-- TemplateException constructor.
--
-- @tparam string _templatePath The path to the template file
-- @tparam mixed[] _templateValues The template values
--
-- @treturn TemplateException The TemplateException instance
--
function TemplateException:__construct(_templatePath, _templateValues)

  local instance = Exception(
    TemplateFactory.getInstance():getTemplate(_templatePath, _templateValues):renderAsText():getOutputRows()[1]
  )
  setmetatable(instance, {__index = TemplateException})

  return instance

end

getmetatable(TemplateException).__call = TemplateException.__construct


return TemplateException
