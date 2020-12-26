---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"
local MapRecord = require("Tops/MapTop/MapRecordList/MapRecord");
local ObjectUtils = require("Util/ObjectUtils");
local StaticString = require("Output/StaticString");

---
-- Saves information about a players score attempt and provides methods to update the score attempt.
--
-- @type PlayerScoreAttempt
--
local PlayerScoreAttempt = setmetatable({}, {});


---
-- The parent player
--
-- @tfield int parentPlayer
--
PlayerScoreAttempt.parentPlayer = nil;

---
-- The start time of the attempt
--
-- @tfield int startTime
--
PlayerScoreAttempt.startTime = nil;

---
-- The end time of the attempt (only set when the player scored)
--
-- @tfield int endTime
--
PlayerScoreAttempt.endTime = nil;

---
-- The id of the weapon of the attempt
-- This will be "KNIFE" initally, but will be updated when the player uses a different weapon
--
-- @tfield int weaponId
--
PlayerScoreAttempt.weaponId = nil;

---
-- The id of the team in which the player is during the attempt
--
-- @tfield int teamId
--
PlayerScoreAttempt.teamId = nil;


---
-- PlayerScoreAttempt constructor.
--
-- @tparam Player _parentPlayer The parent player
--
-- @treturn PlayerScoreAttempt The PlayerScoreAttempt instance
--
function PlayerScoreAttempt:__construct(_parentPlayer)

  local instance = setmetatable({}, {__index = PlayerScoreAttempt});

  instance.parentPlayer = _parentPlayer;
  instance.startTime = -1;
  instance.weaponId = -1;
  instance.teamId = -1;

  return instance;

end

getmetatable(PlayerScoreAttempt).__call = PlayerScoreAttempt.__construct;


-- Getters and Setters

---
-- Returns the parent player.
--
-- @treturn Player The parent player
--
function PlayerScoreAttempt:getParentPlayer()
  return self.parentPlayer;
end

---
-- Sets the parent player
--
-- @tparam Player _parentPlayer The parent player
--
function PlayerScoreAttempt:setParentPlayer(_parentPlayer)
  self.parentPlayer = _parentPlayer;
end

---
-- Returns the attempts start time.
--
-- @treturn int The attempts start time
--
function PlayerScoreAttempt:getStartTime()
  return self.startTime;
end

---
-- Sets the attempts start time.
--
-- @tparam int _startTime The attempts start time
--
function PlayerScoreAttempt:setStartTime(_startTime)
  self.startTime = _startTime;
end

---
-- Returns the attempts weapon id.
--
-- @treturn int The attempts weapon id
--
function PlayerScoreAttempt:getWeaponId()
  return self.weaponId;
end

---
-- Sets the attempts weapon id.
--
-- @tparam int _weaponId The attempts weapon id
--
function PlayerScoreAttempt:setWeaponId(_weaponId)
  self.weaponId = _weaponId;
end

---
-- Returns the attempt team id.
--
-- @treturn int The attempts team id
--
function PlayerScoreAttempt:getTeamId()
  return self.teamId;
end

---
-- Sets the attempt team id.
--
-- @tparam int _teamId The attempt team id
--
function PlayerScoreAttempt:setTeamId(_teamId)
  self.teamId = _teamId;
end


-- Public Methods

---
-- Returns whether the score attempt is finished.
--
-- @treturn bool True if the score attempt is finished, false otherwise
--
function PlayerScoreAttempt:isFinished()

  if (self.endTime) then
    return true;
  else
    return false;
  end

end

---
-- (Re-)Starts the score attempt.
--
function PlayerScoreAttempt:start()
  self.startTime = getsvtick();
  self.endTime = nil;
  self.weaponId = GUN_KNIFE;
end

---
-- Finishes the score attempt.
--
function PlayerScoreAttempt:finish()
  self.endTime = getsvtick();
end

---
-- Creates a MapRecord object from the finished PlayerScoreAttempt.
--
-- @tparam MapRecordList _parentMapRecordList The MapRecordList to which the MapRecord belongs
--
-- @raise Error when the PlayerScoreAttempt is not finished
--
function PlayerScoreAttempt:getMapRecord(_parentMapRecordList)

  if (not self:isFinished()) then
    error(Exception(StaticString("exceptionPlayerScoreAttemptNotFinished"):getString()));
  end

  return MapRecord(
    ObjectUtils:clone(self.parentPlayer),
    self.endTime - self.startTime,
    self.weaponId,
    self.teamId,
    _parentMapRecordList
  );

end


return PlayerScoreAttempt;
