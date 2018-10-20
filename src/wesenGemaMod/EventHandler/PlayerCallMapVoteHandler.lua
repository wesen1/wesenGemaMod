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
local TableUtils = require("Util/TableUtils");

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
-- @tparam Player _player The player that called the vote
-- @tparam string _mapName The map name
-- @tparam int _gameMode The game mode
-- @tparam int _minutes The number of minutes to load the map for
-- @tparam int _voteError The vote error
--
-- @treturn int|nil PLUGIN_BLOCK or nil
--
function PlayerCallMapVoteHandler:onPlayerCallMapVote(_player, _mapName, _gameMode, _minutes, _voteError)
  
  if (_voteError == VOTEE_INVALID) then
    return self:onInvalidMapVote(_player, _mapName, _gameMode, _minutes);
  elseif (_voteError == VOTEE_NOERROR) then
    return self:onValidMapVote(_player, _mapName, _gameMode, _minutes);
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
    self:removeUnplayableMap(_mapName);
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

  local status, exception = pcall(self.mapRemover:removeMap(
    self.parentGemaMode:getDataBase(),
    _mapName,
    self.parentGemaMode:getMapRot()
  ));

  if (not status) then
    if (TableUtils:isInstanceOf(exception, Exception)) then
      self.output:printError(exception:getMessage(), _player);
    else
      error(exception);
    end
  else
    self.output:printInfo("The map \"" .. _mapName .. "\" was automatically deleted because it wasn't playable.", _player);
  end

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
  if (nextGemaModeStateUpdate == true) then
    self.output:printInfo("The gema mode will be automatically enabled if this vote passes.");
  elseif (nextGemaModeStateUpdate == false) then
    self.output:printInfo("The gema mode will be automatically disabled if this vote passes.");
  end

end


return PlayerCallMapVoteHandler;
