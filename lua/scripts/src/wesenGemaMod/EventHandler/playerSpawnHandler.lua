---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- 

---
-- Class that handles player spawns.
--
local PlayerSpawnHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
-- 
-- @param GemaMod parentGemaMod
-- 
PlayerSpawnHandler.parentGemaMod = "";


---
-- PlayerSpawnHandler constructor.
-- 
-- @param GemaMod _parentGemaMod The parent gema mod
--
function PlayerSpawnHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerSpawnHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;
  
end


---
-- Event handler which is called when a player spawns.
-- Initializes the start time of the player that spawned
--
-- @param _cn (int) The client number of the player
--
function PlayerSpawnHandler:onPlayerSpawn(_cn)

  self.parentGemaMod:getPlayers()[_cn]:setStartTime(getsvtick());

end


return PlayerSpawnHandler;
