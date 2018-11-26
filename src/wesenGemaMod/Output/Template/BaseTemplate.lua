---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Parent class for templates.
-- Contains the path to a template file relative from the templates base directory and the values to fill
-- the template with.
--
-- @type BaseTemplate
--
local BaseTemplate = setmetatable({}, {});


---
-- The path to the template file
--
-- @tfield string templatePath
--
BaseTemplate.templatePath = nil;

---
-- The template values that will be used to fill the template
-- This may be a multi dimensional array and may hold objects as values, depending on the template that is used.
--
-- @tfield mixed[] templateValues
--
BaseTemplate.templateValues = nil;


---
-- BaseTemplate constructor.
--
-- @tparam string _templatePath The path to the template file relative from the templates types base folder
-- @tparam mixed[] _templateValues The template values
-- @tparam string _templateType The type of the template (either "TextTemplate" or "TableTemplate")
--
-- @treturn BaseTemplate The BaseTemplate instance
--
function BaseTemplate:__construct(_templatePath, _templateValues, _templateType)

  local instance = setmetatable({}, {__index = BaseTemplate});

  instance.templatePath = _templateType .. "/" .. _templatePath;

  if (_templateValues) then
    instance.templateValues = _templateValues;
  else
    instance.templateValues = {};
  end

  return instance;

end

getmetatable(BaseTemplate).__call = BaseTemplate.__construct;


-- Getters and Setters

---
-- Returns the template path.
--
-- @treturn string The template path
--
function BaseTemplate:getTemplatePath()
  return self.templatePath;
end

---
-- Returns the template values.
--
-- @treturn mixed[] The template values
--
function BaseTemplate:getTemplateValues()
  return self.templateValues;
end


return BaseTemplate;
