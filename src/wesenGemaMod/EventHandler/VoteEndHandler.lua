---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");

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
function VoteEndHandler:onVoteEnd(_result, _player, _type, _text, _number1, _number2)

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

  --@todo: Move auto gema mode switching stuff to own class
  local mapRot = self.parentGemaMode:getMapRot();

  if (_result == 1) then
  -- Vote passed

    local environmentHandler = self.parentGemaMode:getEnvironmentHandler();
    local isNextEnvironmentGemaCompatible = environmentHandler:isNextEnvironmentGemaCompatible();

    if (self.parentGemaMode:getIsActive() and not isNextEnvironmentGemaCompatible) then
      mapRot:loadRegularMapRot();
      self.output:printInfo("Regular maprot loaded.");
    elseif (not self.parentGemaMode:getIsActive() and isNextEnvironmentGemaCompatible) then
      mapRot:loadGemaMapRot();
      self.output:printInfo("Gema map rot loaded.");
    end

  else

    -- Reset the next environment back to the maprots next environment
    self.parentGemaMode:setNextEnvironment(mapRot:getNextEnvironment());

  end

end


return VoteEndHandler;
