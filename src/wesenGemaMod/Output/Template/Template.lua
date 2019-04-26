---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ClientOutputFactory = require("Output/ClientOutput/ClientOutputFactory")
local TemplateNodeTree = require("Output/Template/TemplateNodeTree/TemplateNodeTree")

---
-- Provides methods to render templates as texts or as tables.
--
-- @type Template
--
local Template = setmetatable({}, {})


---
-- The template renderer
--
-- @tfield TemplateRenderer templateRenderer
--
Template.templateRenderer = nil

---
-- The template node tree
--
-- @tfield TemplateNodeTree tree
--
Template.tree = nil

---
-- The path to the template file
--
-- @tfield string templatePath
--
Template.templatePath = nil

---
-- The template values that will be used to fill the template
-- This may be a multi dimensional array and may hold objects as values, depending on the template that is used.
--
-- @tfield mixed[] templateValues
--
Template.templateValues = nil


---
-- Template constructor.
--
-- @tparam TemplateRenderer _templateRenderer The template renderer
-- @tparam string _templatePath The path to the template file relative from the template base folder
-- @tparam mixed[] _templateValues The template values
--
-- @treturn Template The Template instance
--
function Template:__construct(_templateRenderer, _templatePath, _templateValues)

  local instance = setmetatable({}, {__index = Template})

  instance.templateRenderer = _templateRenderer
  instance.templatePath = _templatePath

  if (_templateValues) then
    instance.templateValues = _templateValues
  else
    instance.templateValues = {}
  end

  instance.tree = TemplateNodeTree()

  return instance

end

getmetatable(Template).__call = Template.__construct


-- Getters and Setters

---
-- Returns the template path.
--
-- @treturn string The template path
--
function Template:getTemplatePath()
  return self.templatePath
end

---
-- Returns the template values.
--
-- @treturn mixed[] The template values
--
function Template:getTemplateValues()
  return self.templateValues
end


-- Public Methods

---
-- Creates and returns a text from this Template.
--
-- @tparam bool _returnAsClientOutputString If true the string will be returned as ClientOutputString
--
-- @treturn ClientOutputString|string The text
--
function Template:renderAsText(_returnAsClientOutputString)

  local parsedTemplate = self:parse()

  -- Parse the configuration
  local templateConfiguration = parsedTemplate:find("config")[1]
  if (templateConfiguration) then
    templateConfiguration = templateConfiguration:toTable()
  end

  local outputString = parsedTemplate:find("content")[1]:toString()
  if (_returnAsClientOutputString) then
    return ClientOutputFactory.getInstance():getClientOutputString(outputString, templateConfiguration)
  else
    return outputString
  end

end

---
-- Creates and returns a ClientOutputTable from this Template.
--
-- @treturn ClientOutputTable The ClientOutputTable
--
function Template:renderAsTable()

  local parsedTemplate = self:parse()

  -- Parse the configuration
  local templateConfiguration = parsedTemplate:find("config")[1]
  if (templateConfiguration) then
    templateConfiguration = templateConfiguration:toTable()
  end

  -- Create the ClientOutputTable
  return ClientOutputFactory.getInstance():getClientOutputTable(
    parsedTemplate:find("content")[1]:toTable(), templateConfiguration
  )

end


-- Private Methods

---
-- Renders and parses this template.
--
-- @treturn BaseTemplateNode The root node of the parsed tree
--
function Template:parse()

  local renderedTemplateString = self.templateRenderer:render(self)
  self.tree:parse(renderedTemplateString)

  return self.tree:getRootNode()

end


return Template
