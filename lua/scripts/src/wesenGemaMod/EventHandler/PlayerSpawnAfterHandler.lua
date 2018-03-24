---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Class that handles player spawns.
--
-- @type PlayerSpawnAfterHandler 
--
local PlayerSpawnAfterHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
--
-- @tfield GemaMod parentGemaMod
--
PlayerSpawnAfterHandler.parentGemaMod = "";


---
-- PlayerSpawnAfterHandler constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn PlayerSpawnAfterHandler The PlayerSpawnAfterHandler instance
--
function PlayerSpawnAfterHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerSpawnAfterHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;

end


-- Getters and setters

---
-- Returns the parent gema mod.
--
-- @treturn GemaMod The parent gema mod
--
function PlayerSpawnAfterHandler:getParentGemaMod()
  return self.parentGemaMod;
end

---
-- Sets the parent gema mod.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
function PlayerSpawnAfterHandler:setParentGemaMod(_parentGemaMod)
  self.parentGemaMod = _parentGemaMod;
end


-- Class Methods

---
-- Event handler which is called after a player spawned.
-- Sets the players team and weapon.
--
-- @tparam int _cn The client number of the player who spawned
--
function PlayerSpawnAfterHandler:onPlayerSpawnAfter(_cn)

  local spawnedPlayer = self.parentGemaMod:getPlayers()[_cn];

  spawnedPlayer:setWeapon(getprimary(_cn));
  spawnedPlayer:setTeam(getteam(_cn));

end


return PlayerSpawnAfterHandler;
