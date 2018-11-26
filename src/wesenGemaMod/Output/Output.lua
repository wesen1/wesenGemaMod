---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ObjectUtils = require("Util/ObjectUtils");
local TableTemplateRenderer = require("Output/TemplateRenderer/TableTemplateRenderer");
local TextTemplate = require("Output/Template/TextTemplate");
local TextTemplateRenderer = require("Output/TemplateRenderer/TextTemplateRenderer");

---
-- Handles outputs of texts to clients.
--
-- @type Output
--
local Output = setmetatable({}, {});


---
-- The table template renderer
--
-- @tfield TableTemplateRenderer tableTemplateRenderer
--
Output.tableTemplateRenderer = nil;

---
-- The text template renderer
--
-- @tfield TextTemplateRenderer textTemplateRenderer
--
Output.textTemplateRenderer = nil;


---
-- Output constructor.
--
-- @treturn Output The Output instance
--
function Output:__construct()

  local instance = setmetatable({}, { __index = Output });

  instance.tableTemplateRenderer = TableTemplateRenderer();
  instance.textTemplateRenderer = TextTemplateRenderer("colors");

  return instance;

end

getmetatable(Output).__call = Output.__construct;


-- Public Methods

---
-- Outputs the text that a player says to every other player except for himself.
--
-- @tparam string _text The text that the player says
-- @tparam int _cn The client number of the player
--
function Output:playerSayText(_text, _player)

  -- sayas is used here so that the other players can still use local commands like ignore
  sayas(_text, _player, false, false);
end

---
-- Prints a text template to a player.
--
-- @tparam TextTemplate _textTemplate The text template
-- @tparam Player _player The player to print the template to
--
function Output:printTextTemplate(_textTemplate, _player)
  local renderedTemplate = self.textTemplateRenderer:renderTemplate(_textTemplate);
  self:print(renderedTemplate, _player);
end

---
-- Prints a table template to a player.
--
-- @tparam TableTemplate _tableTemplate The table template
-- @tparam Player _player The player to print the template to
--
function Output:printTableTemplate(_tableTemplate, _player)

  local renderedTable = self.tableTemplateRenderer:renderTemplate(self.textTemplateRenderer, _tableTemplate);
  for _, rowOutputString in ipairs(renderedTable) do
    self:print(rowOutputString, _player);
  end

end

---
-- Displays a error message in the console of a player.
--
-- @tparam string _errorText The error text that will be displayed
-- @tparam int _player The player
--
function Output:printException(_exception, _player)

  local exceptionMessage = _exception:getMessage();
  if (ObjectUtils:isInstanceOf(exceptionMessage, TextTemplate)) then
    exceptionMessage = self.textTemplateRenderer:renderTemplate(exceptionMessage);
  end

  self:printTextTemplate(
    TextTemplate("ServerMessageError", { errorMessage = exceptionMessage }),
    _player
  );
end


-- Private Methods

---
-- Displays text in the console of a player.
--
-- @tparam string _text The text that will be displayed
-- @tparam Player _player The player
--
function Output:print(_text, _player)

  -- -1 targets all connected players
  local cn = -1;

  if (_player ~= nil) then
    cn = _player:getCn();
  end

  clientprint(cn, _text);

end


return Output;
