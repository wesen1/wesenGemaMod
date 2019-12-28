---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local LuaRestyTemplateEngine = require("resty/template")

---
-- Renders template files.
-- Text templates generate single row strings.
-- Leading and trailing whitespace per line, empty lines and line endings are removed.
--
-- @type TemplateRenderer
--
local TemplateRenderer = setmetatable({}, {})


---
-- The default template values that will be passed as arguments to the template renderer
-- The table must be in the format { [valueName] = value, ... }
--
-- @tfield mixed[] defaultTemplateValues
--
TemplateRenderer.defaultTemplateValues = {}

---
-- The base path of the directory in which all templates are stored
-- This will be prepended to every template path
--
-- @tfield string basePath
--
TemplateRenderer.basePath = "."

---
-- The suffix of template files
-- This will be appended to every template path
--
-- @tfield string suffix
--
TemplateRenderer.suffix = ""


---
-- TemplateRenderer constructor.
--
-- @treturn TemplateRenderer The TemplateRenderer instance
--
function TemplateRenderer:__construct()
  local instance = setmetatable({}, {__index = TemplateRenderer})
  return instance
end

getmetatable(TemplateRenderer).__call = TemplateRenderer.__construct


-- Getters and Setters

---
-- Sets the default template values.
--
-- @tparam mixed[] _defaultTemplateValues The default template values
--
function TemplateRenderer:setDefaultTemplateValues(_defaultTemplateValues)
  self.defaultTemplateValues = _defaultTemplateValues
end

---
-- Sets the template base path.
--
-- @tparam string _basePath The template base path
--
function TemplateRenderer:setBasePath(_basePath)
  self.basePath = _basePath
end

---
-- Sets the template sufix.
--
-- @tparam string _suffix The suffix
--
function TemplateRenderer:setSuffix(_suffix)
  self.suffix = _suffix
end


-- Public Methods

---
-- Renders a template and returns the rendered string.
--
-- @tparam Template _template The template to render
--
-- @treturn string The rendered template
--
function TemplateRenderer:render(_template)
  local renderedTemplateString = self:renderTemplate(_template)
  return self:normalizeRenderedTemplate(renderedTemplateString)
end


-- Private Methods

---
-- Combines the default values with the template values and renders the template as is.
--
-- @tparam Template _template The template
--
-- @treturn string The rendered template string
--
function TemplateRenderer:renderTemplate(_template)

  -- Prepare the template values
  local templateValues = _template:getTemplateValues()
  for templateValueName, templateValue in pairs(self.defaultTemplateValues) do
    if (templateValues[templateValueName] == nil) then
      templateValues[templateValueName] = templateValue
    end
  end

  -- Prepare the template
  local templatePath = self.basePath .. "/" .. _template:getTemplatePath() .. self.suffix
  local compiledTemplate = LuaRestyTemplateEngine.compile(templatePath)

  -- Render the template
  return compiledTemplate(templateValues)

end

---
-- Normalizes a rendered template string.
-- This includes whitespace trimming and replacement of special tags.
--
-- @tparam string _renderedTemplateString The rendered template string
--
-- @treturn string The normalized template string
--
function TemplateRenderer:normalizeRenderedTemplate(_renderedTemplateString)

  -- Remove empty lines, leading and trailing whitespace per line and line breaks
  local renderedTemplateString = _renderedTemplateString:gsub(" *\n+ *", "")

  -- Remove leading whitespace from the total string
  renderedTemplateString = renderedTemplateString:gsub("^ *", "")

  -- Find and replace <whitespace> tags
  renderedTemplateString = renderedTemplateString:gsub(
    "< *whitespace[^>]*>",
    function(_whitespaceTagString)
      return self:getWhitespaceTagReplacement(_whitespaceTagString)
    end
  )

  return renderedTemplateString

end

---
-- Returns the corresponding replacemnt for a whitespace tag.
--
-- @tparam string _whitespaceTagString The whitespace tag string
--
-- @treturn string The corresponding number of whitespaces
--
function TemplateRenderer:getWhitespaceTagReplacement(_whitespaceTagString)

  local numberOfWhitespaceCharacters = 1

  -- Check the defined number of whitespace characters (the number behind "whitespace:")
  local definedNumberOfWhitespaceCharactersString = _whitespaceTagString:match(":(%d)")
  if (definedNumberOfWhitespaceCharactersString) then
    local definedNumberOfWhitespaceCharacters = tonumber(definedNumberOfWhitespaceCharactersString)
    if (definedNumberOfWhitespaceCharacters > numberOfWhitespaceCharacters) then
      numberOfWhitespaceCharacters = definedNumberOfWhitespaceCharacters
    end
  end

  return string.rep(" ", numberOfWhitespaceCharacters)

end


return TemplateRenderer
