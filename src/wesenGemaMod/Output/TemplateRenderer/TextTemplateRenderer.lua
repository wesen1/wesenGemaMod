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
-- Leading and trailing whitespace per line, empty lines and line endings are removed.
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

  -- Remove empty lines, leading and trailing whitespace per line and line breaks
  renderedTemplate = renderedTemplate:gsub(" *\n+ *", "");

  -- Remove leading whitespace from the total string
  renderedTemplate = renderedTemplate:gsub("^ *", "");

  -- Find and replace <whitespace> tags
  renderedTemplate = renderedTemplate:gsub(
    "< *whitespace[^>]*>",
    function(_whitespaceTagString)
      local numberOfWhitespaceCharacters = 1;

      -- Check defined number of white space characters (the number behind "whitespace:")
      local definedNumberOfWhitespaceCharactersString = _whitespaceTagString:match(":(%d)");
      if (definedNumberOfWhitespaceCharactersString) then
        local definedNumberOfWhitespaceCharacters = tonumber(definedNumberOfWhitespaceCharactersString);
        if (definedNumberOfWhitespaceCharacters > numberOfWhitespaceCharacters) then
          numberOfWhitespaceCharacters = definedNumberOfWhitespaceCharacters;
        end
      end

      return string.rep(" ", numberOfWhitespaceCharacters);

    end
  );

  return renderedTemplate;

end


return TextTemplateRenderer;
