---
-- @author wesen
-- @copyright 2020-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventEmitter = require "AC-LuaServer.Core.Event.EventEmitter"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Object = require "classic"
local ScoreAttempt = require "GemaScoreManager.ScoreAttempt.ScoreAttempt"

---
-- Provides methods to start, modify and finish the ScoreAttempt's of given players.
--
-- @type ScoreAttemptCollection
--
local ScoreAttemptCollection = Object:extend()
ScoreAttemptCollection:implement(EventEmitter)

---
-- The current ScoreAttempt's per player
-- This list is in the format { <client number> => ScoreAttempt, ... }
--
-- @tfield ScoreAttempt[] scoreAttempts
--
ScoreAttemptCollection.scoreAttempts = nil


---
-- ScoreAttemptCollection constructor.
--
function ScoreAttemptCollection:new()
  self.scoreAttempts = {}

  -- EventEmitter
  self.eventCallbacks = {}
end


-- Public Methods

---
-- Clears this ScoreAttemptCollection.
--
function ScoreAttemptCollection:clear()
  self.scoreAttempts = {}
end

---
-- Starts a ScoreAttempt for a given player.
--
-- @tparam int _cn The client number of the player to start a ScoreAttempt for
--
function ScoreAttemptCollection:startScoreAttempt(_cn)

  -- Cancel the current active ScoreAttempt if required
  if (self.scoreAttempts[_cn]) then
    self:cancelScoreAttempt(_cn, "Next ScoreAttempt started")
  end

  self.scoreAttempts[_cn] = ScoreAttempt(LuaServerApi.getsvtick(), LuaServerApi.getteam(_cn))
  self:emit("scoreAttemptStarted", _cn, self.scoreAttempts[_cn])

end

---
-- Updates the weapon of the ScoreAttempt for a given player if required.
--
-- @tparam int _cn The client number of the player whose ScoreAttempt weapon to update if required
-- @tparam int _weaponId The weapon ID to update the ScoreAttempt with
--
function ScoreAttemptCollection:updateScoreAttemptWeaponIfRequired(_cn, _weaponId)
  if (self.scoreAttempts[_cn]) then
    self.scoreAttempts[_cn]:updateWeaponIfRequired(_weaponId)
  end
end

---
-- Marks the flag as stolen for the ScoreAttempt for a given player.
--
-- @tparam int _cn The client number of the player for whose ScoreAttempt to mark the flag as stolen
--
function ScoreAttemptCollection:markScoreAttemptFlagStolen(_cn)
  if (self.scoreAttempts[_cn] and not self.scoreAttempts[_cn]:getDidStealFlag()) then
    self.scoreAttempts[_cn]:markFlagStolen()
  end
end

---
-- Processes a "flag picked up" event for a given player.
-- Emits the "flagPickedUpWithoutStealing" event if the player picked up the flag without stealing it
-- from its original position during his current ScoreAttempt.
--
-- @tparam int _cn The client number of the player who picked up the flag
--
function ScoreAttemptCollection:processFlagPickup(_cn)
  if (self.scoreAttempts[_cn] and not self.scoreAttempts[_cn]:getDidStealFlag()) then
    self:emit("flagPickedUpWithoutStealing", _cn)
  end
end

---
-- Processes a flag score for a given player.
-- Emits the "scoreAttemptFinished" event if the flag score finishes the current ScoreAttempt of the player.
--
-- @tparam int _cn The client number of the player who scored
--
function ScoreAttemptCollection:processFlagScore(_cn)

  if (self.scoreAttempts[_cn]) then
    self.scoreAttempts[_cn]:finish(LuaServerApi.getsvtick())

    local finishedScoreAttempt = self.scoreAttempts[_cn]
    self.scoreAttempts[_cn] = nil
    self:emit("scoreAttemptFinished", _cn, finishedScoreAttempt)
  end

end

---
-- Cancels a player's ScoreAttempt.
--
-- @tparam int _cn The client number of the player whose ScoreAttempt to cancel
-- @tparam string _reason The reason for the cancellation
--
function ScoreAttemptCollection:cancelScoreAttempt(_cn, _reason)

  if (self.scoreAttempts[_cn]) then
    local cancelledScoreAttempt = self.scoreAttempts[_cn]
    self.scoreAttempts[_cn] = nil
    self:emit("scoreAttemptCancelled", _cn, cancelledScoreAttempt, _reason)
  end

end

---
-- Cancels the ScoreAttempt's of all players.
--
-- @tparam string _reason The reason for the cancellation
--
function ScoreAttemptCollection:cancelAllScoreAttempts(_reason)
  for cn, _ in pairs(self.scoreAttempts) do
    self:cancelScoreAttempt(cn, _reason)
  end
end


return ScoreAttemptCollection
