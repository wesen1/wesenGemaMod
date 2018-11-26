---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");
local TextTemplate = require("Output/Template/TextTemplate");

---
-- Class that handles vote ends.
-- VoteEndHandler inherits from BaseEventHandler
--
-- @type VoteEndHandler
--
local VoteEndHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- VoteEndHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn VoteEndHandler The VoteEndHandler instance
--
function VoteEndHandler:__construct(_parentGemaMode)

  local instance = BaseEventHandler(_parentGemaMode);
  setmetatable(instance, {__index = VoteEndHandler});

  return instance;

end

getmetatable(VoteEndHandler).__call = VoteEndHandler.__construct;


-- Class Methods

---
-- Event handler which is called when a vote ends.
--
-- @tparam int _result The result of the vote
-- @tparam Player _player The player who called the vote
-- @tparam int _type The vote type
-- @tparam string _text The map name, kick reason, etc.
-- @tparam int _number1 The game mode, target cn, etc.
-- @tparam int _number2 The time of the map vote, target team of teamchange vote, etc.
--
function VoteEndHandler:handleEvent(_result, _player, _type, _text, _number1, _number2)

  if (_type == SA_MAP) then
    self:onMapVoteEnd(_result, _player, _text, _number1, _number2);
  end

end

---
-- Handles map vote results.
--
-- @tparam int _result The result of the vote
-- @tparam Player _player The player who called the vote
-- @tparam string _mapName The map name
-- @tparam int _gameMode The game mode
-- @tparam int _minutes The minutes to load the map for
--
function VoteEndHandler:onMapVoteEnd(_result, _player, _mapName, _gameMode, _minutes)

  local gemaModeStateUpdater = self.parentGemaMode:getGemaModeStateUpdater();

  if (_result == 1) then
    -- Vote passed

    local mapRot = self.parentGemaMode:getMapRot();

    local nextGemaModeStateUpdate = gemaModeStateUpdater:getNextGemaModeStateUpdate();
    if (nextGemaModeStateUpdate == true) then
      mapRot:loadGemaMapRot();
    elseif (nextGemaModeStateUpdate == false) then
      mapRot:loadRegularMapRot();
    end

    if (nextGemaModeStateUpdate ~= nil) then
      self.output:printTextTemplate(
        TextTemplate("InfoMessages/MapRot/MapRotLoaded", { ["mapRotType"] = mapRot:getType() })
      );
    end

  else
    gemaModeStateUpdater:resetNextEnvironment();
  end

end


return VoteEndHandler;
