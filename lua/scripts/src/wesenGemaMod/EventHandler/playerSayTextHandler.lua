---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- 

local Output = require("Outputs/Output");


---
-- Class that handles players saying texts.
--
local PlayerSayTextHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
-- 
-- @param GemaMod parentGemaMod
-- 
PlayerSayTextHandler.parentGemaMod = "";


---
-- PlayerSayTextHandler constructor.
-- 
-- @param GemaMod _parentGemaMod The parent gema mod
--
function PlayerSayTextHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerSayTextHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;
  
end


---
-- Event handler which is called when a player says text.
-- Logs the text that the player said and either executes a command or outputs the text to the other players
--
-- @param _cn (int) The client number of the player
-- @param _text (String) The text that the player sent
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

    Output:playerSayText(_text, _cn);

    -- block the normal player text output of the server
    return PLUGIN_BLOCK;

  end

end


return PlayerSayTextHandler;
