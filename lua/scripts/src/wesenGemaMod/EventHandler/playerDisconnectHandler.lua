---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- 

---
-- Class that handles player disconnects.
--
local PlayerDisconnectHandler = {};


---
-- The parent gema mod to which this EventHandler belongs.
-- 
-- @param GemaMod parentGemaMod
-- 
PlayerDisconnectHandler.parentGemaMod = "";


---
-- PlayerDisconnectHandler constructor.
-- 
-- @param GemaMod _parentGemaMod The parent gema mod
--
function PlayerDisconnectHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerDisconnectHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;
  
end

---
-- Event handler which is called when a player disconnects.
-- Unsets the player object of the cn and prints an error message in case of a banned player trying to connect
--
-- @param _cn (int) The client number of the player
-- @param _reason (int) The disconnect reason
--
function PlayerDisconnectHandler:onPlayerDisconnect(_cn, _reason)

  if (_reason == DISC_BANREFUSE) then
    
    local errorMessage = string.format("Error: %s could not connect [banned]", getname(cn));
    self.parentGemaMod:output():print(colorLoader:getColor("error") .. errorMessage);

  end

  self.parentGemaMod:removePlayer(_cn);

end


return PlayerDisconnectHandler;
