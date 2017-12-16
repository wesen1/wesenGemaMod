---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

require("CommandParser");
require("Output");

---
-- Event handler which is called when a player says text.
-- Logs the text that the player said and either executes a command or outputs the text to the other players
--
-- @param _cn (int) Client number of the player
-- @param _text (String) Text that the player sent
--
function onPlayerSayText(_cn, _text)
  
  local playerIp = players[_cn]:getIp();
  local playerName = players[_cn]:getName();
  local logText = string.format("[%s] %s says: '%s'", playerIp, playerName, _text);

  logline(4, logText);

  if (CommandParser:isCommand(_text)) then
    CommandParser:parseCommand(_text, _cn);

  else

    Output:playerSayText(_text, _cn);

    -- block the normal player text output of the server
    return PLUGIN_BLOCK;

  end

end