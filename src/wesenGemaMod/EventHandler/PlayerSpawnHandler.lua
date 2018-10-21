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

  local instance = BaseEventHandler(_parentGemaMode);
  setmetatable(instance, {__index = PlayerSpawnHandler});

  return instance;

end

getmetatable(PlayerSpawnHandler).__call = PlayerSpawnHandler.__construct;


-- Class Methods

---
-- Event handler which is called when a player spawns.
--
-- @tparam Player _player The player who spawned
--
function PlayerSpawnHandler:onPlayerSpawn(_player)

  if (self.parentGemaMode:getIsActive()) then
    _player:getScoreAttempt():start();
  end

end


return PlayerSpawnHandler;
