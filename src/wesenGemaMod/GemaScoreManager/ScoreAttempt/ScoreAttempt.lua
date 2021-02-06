---
-- @author wesen
-- @copyright 2018-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Object = require "classic"
local ScoreAttemptAlreadyFinishedException = require "GemaScoreManager.ScoreAttempt.Exception.ScoreAttemptAlreadyFinishedException"
local ScoreAttemptNotFinishedException = require "GemaScoreManager.ScoreAttempt.Exception.ScoreAttemptNotFinishedException"

---
-- Represents a Player's attempt to score.
--
-- @type ScoreAttempt
--
local ScoreAttempt = Object:extend()

---
-- The start timestamp of the attempt in milliseconds
--
-- @tfield int startTimestamp
--
ScoreAttempt.startTimestamp = nil

---
-- The end timestamp of the attempt in milliseconds
-- This will be nil until finish() was called
--
-- @tfield int endTimestamp
--
ScoreAttempt.endTimestamp = nil

---
-- The ID of the "best" weapon that was used during the attempt
--
-- This will be "KNIFE" initially.
-- If the player uses "PISTOL" or "AKIMBO" it will be updated to "PISTOL".
-- If the player uses his primary weapon it will be updated to <primary weapon>.
--
-- @tfield int weaponId
--
ScoreAttempt.weaponId = nil

---
-- The ID of the team to which the player belongs during the attempt
--
-- @tfield int teamId
--
ScoreAttempt.teamId = nil


---
-- ScoreAttempt constructor.
--
-- @tparam int _startTimestamp The start timestamp of the attempt in milliseconds
-- @tparam int _teamId The ID of the team to which the player belongs during the attempt
--
function ScoreAttempt:new(_startTimestamp, _teamId)
  self.startTimestamp = _startTimestamp
  self.endTimestamp = nil
  self.weaponId = LuaServerApi.GUN_KNIFE
  self.teamId = _teamId
end


-- Getters and Setters

---
-- Returns the ID of the "best" weapon that was used during the attempt.
--
-- @treturn int The weapon ID
--
function ScoreAttempt:getWeaponId()
  return self.weaponId
end

---
-- Returns the ID of the team to which the player belongs during the attempt.
--
-- @treturn int The team ID
--
function ScoreAttempt:getTeamId()
  return self.teamId
end


-- Public Methods

---
-- Returns whether the attempt is finished.
--
-- @treturn bool True if the attempt is finished, false otherwise
--
function ScoreAttempt:isFinished()
  return (self.endTimestamp ~= nil)
end

---
-- Updates the "best" used weapon of the attempt if required.
--
-- @tparam int _usedWeaponId The ID of the weapon that the player used
--
-- @raise The Exception when the ScoreAttempt is already finished
--
function ScoreAttempt:updateWeaponIfRequired(_usedWeaponId)

  if (self:isFinished()) then
    error(ScoreAttemptAlreadyFinishedException("weaponId"))
  end

  if (_usedWeaponId == LuaServerApi.GUN_KNIFE or _usedWeaponId == LuaServerApi.GUN_GRENADE) then
    -- The used weapon is not one that can change the weapon of a ScoreAttempt
    return
  elseif (self.weaponId ~= LuaServerApi.GUN_KNIFE and self.weaponId ~= LuaServerApi.GUN_PISTOL) then
    -- The current weapon of this ScoreAttempt already is a primary weapon, so it can no longer be changed
    return
  end

  local usedWeaponIsPistol = (_usedWeaponId == LuaServerApi.GUN_PISTOL or _usedWeaponId == LuaServerApi.GUN_AKIMBO)
  if (self.weaponId == LuaServerApi.GUN_KNIFE) then
    self.weaponId = usedWeaponIsPistol and LuaServerApi.GUN_PISTOL or _usedWeaponId
  elseif (self.weaponId == LuaServerApi.GUN_PISTOL and not usedWeaponIsPistol) then
    self.weaponId = _usedWeaponId
  end

end

---
-- Finishes the attempt.
--
-- @tparam int _endTimestamp The end timestamp of the attempt in milliseconds
--
-- @raise The Exception when the ScoreAttempt is already finished
--
function ScoreAttempt:finish(_endTimestamp)
  if (self:isFinished()) then
    error(ScoreAttemptAlreadyFinishedException("endTimestamp"))
  end

  self.endTimestamp = _endTimestamp
end

---
-- Returns the time that the player took to score during the attempt in milliseconds.
--
-- @treturn int The time it took the player to score in milliseconds
--
-- @raise The error when the ScoreAttempt was not finished yet
--
function ScoreAttempt:getDuration()
  if (not self:isFinished()) then
    error(ScoreAttemptNotFinishedException("duration"))
  end

  return (self.endTimestamp - self.startTimestamp)
end


return ScoreAttempt
