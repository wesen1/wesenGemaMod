---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Template = require("Output/Template/Template")
local TemplateRenderer = require("Output/Template/TemplateRenderer")

---
-- Provides static methods to to create Template instances.
--
-- @type TemplateFactory
--
local TemplateFactory = setmetatable({}, {})


---
-- The TemplateFactory instance that will be returned by the getInstance method
--
-- @tfield TemplateFactory instance
--
TemplateFactory.instance = nil

---
-- The template renderer for Template instances
--
-- @tfield TemplateRenderer templateRenderer
--
TemplateFactory.templateRenderer = nil


---
-- TemplateFactory constructor.
--
-- @treturn TemplateFactory The TemplateFactory instance
--
function TemplateFactory:__construct()

  local instance = setmetatable({}, {__index = TemplateFactory})
  instance.templateRenderer = TemplateRenderer()

  return instance

end

getmetatable(TemplateFactory).__call = TemplateFactory.__construct


-- Public Methods

---
-- Returns a TemplateFactory instance.
-- This will return the same instance on subsequent calls.
--
-- @treturn TemplateFactory The TemplateFactory instance
--
function TemplateFactory.getInstance()

  if (TemplateFactory.instance == nil) then
    TemplateFactory.instance = TemplateFactory()
  end

  return TemplateFactory.instance

end

---
-- Configures this TemplateFactory.
--
-- @tparam table _configuration The configuration
--
function TemplateFactory:configure(_configuration)

  if (_configuration["templateRenderer"] ~= nil) then
    self:configureTemplateRenderer(_configuration["templateRenderer"])
  end

end

---
-- Creates and returns a Template instance.
--
-- @tparam string _templatePath The template path
-- @tparam mixed[] _templateValues The template values
--
-- @treturn Template The template instance
--
function TemplateFactory:getTemplate(_templatePath, _templateValues)
  return Template(self.templateRenderer, _templatePath, _templateValues)
end


-- Private Methods

---
-- Configures the template renderer of this TemplateFactory.
--
-- @tparam string[] _templateRendererConfiguration The template renderer configuration
--
function TemplateFactory:configureTemplateRenderer(_templateRendererConfiguration)

  if (_templateRendererConfiguration["defaultTemplateValues"] ~= nil) then
    self.templateRenderer:setDefaultTemplateValues(_templateRendererConfiguration["defaultTemplateValues"])
  end

  if (_templateRendererConfiguration["basePath"] ~= nil) then
    self.templateRenderer:setBasePath(_templateRendererConfiguration["basePath"])
  end

  if (_templateRendererConfiguration["suffix"] ~= nil) then
    self.templateRenderer:setSuffix(_templateRendererConfiguration["suffix"])
  end

end


return TemplateFactory
