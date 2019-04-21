---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");
local Environment = require("EnvironmentHandler/Environment");
local Exception = require("Util/Exception");
local MapRemover = require("Map/MapRemover");
local ObjectUtils = require("Util/ObjectUtils");
local TextTemplate = require("Output/Template/TextTemplate");

---
-- Handles map votes.
-- PlayerCallMapVoteHandler inherits from BaseEventHandler
--
-- @type PlayerCallMapVoteHandler
--
local PlayerCallMapVoteHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- The map remover
--
-- @tfield MapRemover mapRemover
--
PlayerCallMapVoteHandler.mapRemover = nil;


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

  instance.mapRemover = MapRemover();

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

  if (_voteError == VOTEE_INVALID) then
    return self:onInvalidMapVote(player, _mapName, _gameMode, _minutes)
  elseif (_voteError == VOTEE_NOERROR) then
    return self:onValidMapVote(player, _mapName, _gameMode, _minutes)
  end

end


-- Private Methods

---
-- Handles invalid map votes.
--
-- @tparam Player _player The player that called the vote
-- @tparam string _mapName The map name
-- @tparam int _gameMode The game mode
-- @tparam int _minutes The number of minutes to load the map for
--
-- @treturn int|nil PLUGIN_BLOCK or nil
--
function PlayerCallMapVoteHandler:onInvalidMapVote(_player, _mapName, _gameMode, _minutes)

  if (mapexists(_mapName)) then
    -- The map exists but the vote is invalid, this means that the map can not be loaded because it is unplayable

    local status, exception = pcall(self.removeUnplayableMap, self, _mapName);
    if (not status) then
      if (ObjectUtils:isInstanceOf(exception, Exception)) then
       self.output:printException(exception, _player);
      else
        error(exception);
      end
    end

    return PLUGIN_BLOCK;
  end

end

---
-- Removes an unplayable map from the maprot and the maps folder.
--
-- @tparam string _mapName The map name
-- @tparam Player _player The player who tried to load the map
--
function PlayerCallMapVoteHandler:removeUnplayableMap(_mapName, _player)

  self.mapRemover:removeMap(_mapName, self.parentGemaMode:getMapRot());

  self.output:printTextTemplate(
    TextTemplate(
      "InfoMessages/Maps/AutomaticMapDeletion", { ["mapName"] = _mapName }
    ), _player
  );

end

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
      TextTemplate(
        "InfoMessages/GemaModeState/GemaModeStateChangeOnVotePass",
        { ["voteWillEnableGemaMode"] = nextGemaModeStateUpdate }
      )
    );
  end

end


return PlayerCallMapVoteHandler;
