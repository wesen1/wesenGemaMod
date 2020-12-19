---
-- @author wesen
-- @copyright 2017-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TemplateFactory = require("Output/Template/TemplateFactory")

---
-- Handles outputs of texts to clients.
--
-- @type Output
--
local Output = setmetatable({}, {})


---
-- The table template renderer
--
-- @tfield TableTemplateRenderer tableTemplateRenderer
--
Output.tableTemplateRenderer = nil

---
-- The text template renderer
--
-- @tfield TextTemplateRenderer textTemplateRenderer
--
Output.textTemplateRenderer = nil


---
-- Output constructor.
--
-- @treturn Output The Output instance
--
function Output:__construct()
  local instance = setmetatable({}, {__index = Output})
  return instance
end

getmetatable(Output).__call = Output.__construct


-- Public Methods

---
-- Outputs the text that a player says to every other player except for himself.
--
-- @tparam string _text The text that the player says
-- @tparam int _cn The client number of the player
--
function Output:playerSayText(_text, _player)

  -- sayas is used here so that the other players can still use local commands like ignore
  sayas(_text, _player, false, false)
end

---
-- Prints a template to a player.
--
-- @tparam Template _template The template
-- @tparam Player _player The player to the print the template to
--
function Output:printTemplate(_template, _player)
  for _, row in ipairs(_template:getOutputRows()) do
    self:print(row, _player)
  end
end

---
-- Prints a text template to a player.
--
-- @tparam string _templatePath The path to the template
-- @tparam table _templateValues The template values
-- @tparam Player _player The player to print the template to
--
function Output:printTextTemplate(_templatePath, _templateValues, _player)
  local template = TemplateFactory.getInstance():getTemplate(_templatePath, _templateValues)
  template:renderAsText(true)

  self:printTemplate(template, _player)
end

---
-- Prints a table template to a player.
--
-- @tparam string _templatePath The path to the template
-- @tparam table _templateValues The template values
-- @tparam Player _player The player to print the template to
--
function Output:printTableTemplate(_templatePath, _templateValues, _player)
  local template = TemplateFactory.getInstance():getTemplate(_templatePath, _templateValues)
  template:renderAsTable()

  self:printTemplate(template, _player)
end

---
-- Displays a error message in the console of a player.
--
-- @tparam string _errorText The error text that will be displayed
-- @tparam int _player The player
--
function Output:printException(_exception, _player)
  self:printTextTemplate(
    "TextTemplate/ServerMessageError", { errorMessage = _exception:getMessage() }, _player
  )
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
  local cn = -1

  if (_player ~= nil) then
    cn = _player:getCn()
  end

  clientprint(cn, _text)

end


return Output
