---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Output = require("Outputs/Output");

---
-- @type PlayerSayTextHandler Class that handles players saying texts.
--
local PlayerSayTextHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
--
-- @tfield GemaMod parentGemaMod
--
PlayerSayTextHandler.parentGemaMod = "";


---
-- PlayerSayTextHandler constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn PlayerSayTextHandler The PlayerSayTextHandler instance
--
function PlayerSayTextHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerSayTextHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;

end


-- Getters and setters

---
-- Returns the parent gema mod.
--
-- @treturn GemaMod The parent gema mod
--
function PlayerSayTextHandler:getParentGemaMod()
  return self.parentGemaMod;
end

---
-- Sets the parent gema mod.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
function PlayerSayTextHandler:setParentGemaMod(_parentGemaMod)
  self.parentGemaMod = _parentGemaMod;
end


-- Class Methods

---
-- Event handler which is called when a player says text.
-- Logs the text that the player said and either executes a command or outputs the text to the other players
--
-- @tparam int _cn The client number of the player
-- @tparam string _text The text that the player sent
--
-- @treturn int|nil PLUGIN_BLOCK if the player says normal text or nil
--
function PlayerSayTextHandler:onPlayerSayText(_cn, _text)

  local playerIp = self.parentGemaMod:getPlayers()[_cn]:getIp();
  local playerName = self.parentGemaMod:getPlayers()[_cn]:getName();
  local logText = string.format("[%s] %s says: '%s'", playerIp, playerName, _text);

  logline(4, logText);

  local commandParser = self.parentGemaMod:getCommandHandler():getCommandParser();

  if (commandParser:isCommand(_text)) then
    commandParser:parseCommand(_text, _cn);
  else
    Output:playerSayText(_text, _cn, self.parentGemaMod:getPlayers());
  end

  -- block the normal player text output of the server
  return PLUGIN_BLOCK;

end


return PlayerSayTextHandler;
