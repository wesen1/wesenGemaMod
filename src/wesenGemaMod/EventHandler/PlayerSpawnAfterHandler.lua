---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");

---
-- Class that handles player spawns.
-- PlayerSpawnAfterHandler inherits from BaseEventHandler
--
-- @type PlayerSpawnAfterHandler
--
local PlayerSpawnAfterHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- PlayerSpawnAfterHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn PlayerSpawnAfterHandler The PlayerSpawnAfterHandler instance
--
function PlayerSpawnAfterHandler:__construct(_parentGemaMode)

  local instance = BaseEventHandler(_parentGemaMode);
  setmetatable(instance, {__index = PlayerSpawnAfterHandler});

  return instance;

end

getmetatable(PlayerSpawnAfterHandler).__call = PlayerSpawnAfterHandler.__construct;


-- Class Methods

---
-- Event handler which is called after a player spawned.
-- Sets the players team.
-- @todo: Explain why this is done onplayerspawnafter and not in onplayerspawn!
--
-- @tparam Player _player The player who spawned
--
function PlayerSpawnAfterHandler:handleEvent(_player)

  if (self.parentGemaMode:getIsActive()) then

    -- The team id set in the PlayerSpawnAfterHandler because @todo
    _player:getScoreAttempt():setTeamId(getteam(_player:getCn()));
  end

end


return PlayerSpawnAfterHandler;
