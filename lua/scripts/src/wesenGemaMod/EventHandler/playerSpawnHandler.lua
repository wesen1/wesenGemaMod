---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Class that handles player spawns.
--
-- @type PlayerSpawnHandler 
--
local PlayerSpawnHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
--
-- @tfield GemaMod parentGemaMod
--
PlayerSpawnHandler.parentGemaMod = "";


---
-- PlayerSpawnHandler constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn PlayerSpawnHandler The PlayerSpawnHandler instance
--
function PlayerSpawnHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerSpawnHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;

end


-- Getters and setters

---
-- Returns the parent gema mod.
--
-- @treturn GemaMod The parent gema mod
--
function PlayerSpawnHandler:getParentGemaMod()
  return self.parentGemaMod;
end

---
-- Sets the parent gema mod.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
function PlayerSpawnHandler:setParentGemaMod(_parentGemaMod)
  self.parentGemaMod = _parentGemaMod;
end


-- Class Methods

---
-- Event handler which is called when a player spawns.
-- Initializes the start time of the player that spawned
--
-- @tparam int _cn The client number of the player who spawned
--
function PlayerSpawnHandler:onPlayerSpawn(_cn)
  self.parentGemaMod:getPlayers()[_cn]:setStartTime(getsvtick());
end


return PlayerSpawnHandler;
