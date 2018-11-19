---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ColorLoader = require("Output/Util/ColorLoader");
local TemplateEngine = require("Output/TemplateRenderer/TemplateEngine");
local TimeFormatter = require("TimeHandler/TimeFormatter");

---
-- Renders text templates.
-- Text templates generate single row strings.
-- Trailing whitespace per line and line endings as well as leading whitespace of the total string are discarded.
--
-- @type TextTemplateRenderer
--
local TextTemplateRenderer = setmetatable({}, {});


---
-- The color loader
--
-- @tfield ColorLoader colorLoader
--
TextTemplateRenderer.colorLoader = nil;


function TextTemplateRenderer:__construct(_colorConfigurationFileName)

  local instance = setmetatable({}, {__index = TextTemplateRenderer});

  instance.colorLoader = ColorLoader(_colorConfigurationFileName);
  instance.timeFormatter = TimeFormatter();

  return instance;

end

getmetatable(TextTemplateRenderer).__call = TextTemplateRenderer.__construct;


---
-- Renders a template and returns the rendered string.
--
-- @tparam TextTemplate _textTemplate The text template
--
-- @treturn string The rendered text template
--
function TextTemplateRenderer:renderTemplate(_textTemplate)

  -- Prepare the template values
  local templateValues = _textTemplate:getTemplateValues();
  templateValues["colors"] = self.colorLoader:getColors();
  templateValues["timeFormatter"] = self.timeFormatter;

  -- Prepare the template
  local compiledTemplate = TemplateEngine.compile(_textTemplate:getTemplatePath());

  -- Render the template
  local renderedTemplate = compiledTemplate(templateValues);

  -- Remove trailing whitespace and the line break of each output line
  renderedTemplate = renderedTemplate:gsub(" *\n", "");

  -- Remove leading whitespace from the total string
  renderedTemplate = renderedTemplate:gsub("^ *", "");

  return renderedTemplate;

end


return TextTemplateRenderer;
