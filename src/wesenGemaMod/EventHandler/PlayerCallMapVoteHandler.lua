---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");
local Environment = require("EnvironmentHandler/Environment");
local Exception = require("Util/Exception");
local ObjectUtils = require("Util/ObjectUtils");

---
-- Handles map votes.
-- PlayerCallMapVoteHandler inherits from BaseEventHandler
--
-- @type PlayerCallMapVoteHandler
--
local PlayerCallMapVoteHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- PlayerCallMapVoteHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn PlayerCallMapVoteHandler The PlayerCallMapVoteHandler instance
--
function PlayerCallMapVoteHandler:__construct(_parentGemaMode)

  -- This is no lua server event, therefore no target event name is added to this event handler
  local instance = BaseEventHandler(_parentGemaMode);
  setmetatable(instance, {__index = PlayerCallMapVoteHandler});

  return instance;

end

getmetatable(PlayerCallMapVoteHandler).__call = PlayerCallMapVoteHandler.__construct;


-- Public Methods

---
-- Handles map votes.
--
-- @tparam int _cn The client number of the player that called the vote
-- @tparam string _mapName The map name
-- @tparam int _gameMode The game mode
-- @tparam int _minutes The number of minutes to load the map for
-- @tparam int _voteError The vote error
--
-- @treturn int|nil PLUGIN_BLOCK or nil
--
function PlayerCallMapVoteHandler:handleEvent(_cn, _mapName, _gameMode, _minutes, _voteError)

  local player = self:getPlayerByCn(_cn)

  if (_voteError == VOTEE_NOERROR) then
    return self:onValidMapVote(player, _mapName, _gameMode, _minutes)
  end

end


-- Private Methods

---
-- Handles valid map votes.
--
-- @tparam Player _player The player that called the vote
-- @tparam string _mapName The map name
-- @tparam int _gameMode The game mode
-- @tparam int _minutes The number of minutes to load the map for
--
function PlayerCallMapVoteHandler:onValidMapVote(_player, _mapName, _gameMode, _minutes)

  local gemaModeStateUpdater = self.parentGemaMode:getGemaModeStateUpdater();
  gemaModeStateUpdater:setNextEnvironment(Environment(_mapName, _gameMode));

  local nextGemaModeStateUpdate = gemaModeStateUpdater:getNextGemaModeStateUpdate();

  if (nextGemaModeStateUpdate ~= nil) then
    self.output:printTextTemplate(
      "TextTemplate/InfoMessages/GemaModeState/GemaModeStateChangeOnVotePass",
      { ["voteWillEnableGemaMode"] = nextGemaModeStateUpdate }
    )
  end

end


return PlayerCallMapVoteHandler;
