---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");

---
-- Class that handles player spawns.
-- PlayerSpawnHandler inherits from BaseEventHandler
--
-- @type PlayerSpawnHandler
--
local PlayerSpawnHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- PlayerSpawnHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn PlayerSpawnHandler The PlayerSpawnHandler instance
--
function PlayerSpawnHandler:__construct(_parentGemaMode)

  local instance = BaseEventHandler(_parentGemaMode, "onPlayerSpawn");
  setmetatable(instance, {__index = PlayerSpawnHandler});

  return instance;

end

getmetatable(PlayerSpawnHandler).__call = PlayerSpawnHandler.__construct;


-- Class Methods

---
-- Event handler which is called when a player spawns.
--
-- @tparam int _cn The client number of the player who spawned
--
function PlayerSpawnHandler:handleEvent(_cn)

  if (self.parentGemaMode:getIsActive()) then

    local player = self:getPlayerByCn(_cn)

    player:getScoreAttempt():start();
    player:getScoreAttempt():setTeamId(getteam(_cn));
  end

end


return PlayerSpawnHandler;
