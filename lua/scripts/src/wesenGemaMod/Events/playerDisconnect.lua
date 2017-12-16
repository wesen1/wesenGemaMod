---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

require("Output");

---
-- Event handler which is called when a player disconnects.
-- Unsets the player object of the cn and prints an error message in case of a banned player trying to connect
--
-- @param _cn (int) Client number of the player
-- @param _reason (int) Disconnect reason
--
function onPlayerDisconnect(_cn, _reason)

  if (_reason == DISC_BANREFUSE) then
    
    local errorMessage = string.format("Error: %s could not connect [banned]", getname(cn));
    Output:print(colorLoader:getColor("error") .. errorMessage);
    
  end
  
  players[_cn] = nil;
  
end