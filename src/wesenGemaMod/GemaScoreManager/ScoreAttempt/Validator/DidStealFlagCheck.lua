---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local ScoreAttemptValidationCheck = require "GemaScoreManager.ScoreAttempt.Validator.ScoreAttemptValidationCheck"
local Server = require "AC-LuaServer.Core.Server"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"
local StaticString = require "Output.StaticString"

---
-- Validation check that tracks whether the players steal the flag from its original position before scoring.
--
-- @type DidStealFlagCheck
--
local DidStealFlagCheck = ScoreAttemptValidationCheck:extend()
DidStealFlagCheck:implement(ServerEventListener)

---
-- Stores which players did steal the flag from its original position during their current ScoreAttempt's
-- This list is in the format { <client number> => <bool>, ... }
--
-- @tfield bool[] playersWhoStoleTheFlag
--
DidStealFlagCheck.playersWhoStoleTheFlag = nil

---
-- EventCallback for the "scoreAttemptStarted" event of the ScoreAttemptCollection
--
-- @tfield EventCallback onScoreAttemptStartedEventCallback
--
DidStealFlagCheck.onScoreAttemptStartedEventCallback = nil

---
-- EventCallback for the "scoreAttemptFinished" event of the ScoreAttemptCollection
-- This should have a really low priority to make sure that it is not called before the ScoreAttemptManager
-- asks if the finished ScoreAttempt is valid
--
-- @tfield EventCallback onScoreAttemptFinishedEventCallback
--
DidStealFlagCheck.onScoreAttemptFinishedEventCallback = nil

---
-- EventCallback for the "scoreAttemptCancelled" event of the ScoreAttemptCollection
--
-- @tfield EventCallback onScoreAttemptCancelledEventCallback
--
DidStealFlagCheck.onScoreAttemptCancelledEventCallback = nil

---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
DidStealFlagCheck.serverEventListeners = {
  onFlagAction = "onFlagAction"
}


---
-- DidStealFlagCheck constructor.
--
function DidStealFlagCheck:new()
  self.playersWhoStoleTheFlag = {}

  self.onScoreAttemptStartedEventCallback = EventCallback({ object = self, methodName = "onScoreAttemptStarted" })
  self.onScoreAttemptFinishedEventCallback = EventCallback({ object = self, methodName = "onScoreAttemptFinished" }, 256)
  self.onScoreAttemptCancelledEventCallback = EventCallback({ object = self, methodName = "onScoreAttemptCancelled" })
end


-- Public Methods

---
-- Initializes this ScoreAttemptValidationCheck.
--
function DidStealFlagCheck:initialize()
  self:registerAllServerEventListeners()

  local gemaScoreManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaScoreManager")
  local scoreAttemptCollection = gemaScoreManager:getScoreAttemptManager():getScoreAttemptCollection()
  scoreAttemptCollection:on("scoreAttemptStarted", self.onScoreAttemptStartedEventCallback)
  scoreAttemptCollection:on("scoreAttemptFinished", self.onScoreAttemptFinishedEventCallback)
  scoreAttemptCollection:on("scoreAttemptCancelled", self.onScoreAttemptCancelledEventCallback)
end

---
-- Terminates this ScoreAttemptValidationCheck.
--
function DidStealFlagCheck:terminate()
  self:unregisterAllServerEventListeners()

  local gemaScoreManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaScoreManager")
  local scoreAttemptCollection = gemaScoreManager:getScoreAttemptManager():getScoreAttemptCollection()
  scoreAttemptCollection:off("scoreAttemptStarted", self.onScoreAttemptStartedEventCallback)
  scoreAttemptCollection:off("scoreAttemptFinished", self.onScoreAttemptFinishedEventCallback)
  scoreAttemptCollection:off("scoreAttemptCancelled", self.onScoreAttemptCancelledEventCallback)
end

---
-- Checks whether a given ScoreAttempt is valid.
-- Will return true if the player did steal the flag from its original position
-- during his current ScoreAttempt.
--
-- @tparam int _cn The client number of the player to which the ScoreAttempt belongs
-- @tparam ScoreAttempt _scoreAttempt The ScoreAttempt to validate
--
-- @treturn bool True if the ScoreAttempt is valid, false otherwise
--
function DidStealFlagCheck:isScoreAttemptValid(_cn, _scoreAttempt)
  return (self.playersWhoStoleTheFlag[_cn] == true)
end

---
-- Returns the error message that explains why a ScoreAttempt was not valid that
-- did not meet this check's conditions.
--
-- @treturn string The error message
--
function DidStealFlagCheck:getErrorMessage()
  return StaticString("didStealFlagCheckErrorMessage")
end


-- Event handlers

---
-- Event handler that is called when a ScoreAttempt is started.
--
-- @tparam int _cn The client number of the player whose ScoreAttempt was started
--
function DidStealFlagCheck:onScoreAttemptStarted(_cn)
  self.playersWhoStoleTheFlag[_cn] = false
end

---
-- Event handler that is called when a ScoreAttempt is finished.
--
-- @tparam int _cn The client number of the player whose ScoreAttempt was finished
--
function DidStealFlagCheck:onScoreAttemptFinished(_cn)
  self.playersWhoStoleTheFlag[_cn] = nil
end

---
-- Event handler that is called when a ScoreAttempt is cancelled.
--
-- @tparam int _cn The client number of the player whose ScoreAttempt was cancelled
--
function DidStealFlagCheck:onScoreAttemptCancelled(_cn)
  self.playersWhoStoleTheFlag[_cn] = nil
end

---
-- Event handler that is called when the state of the flag is changed.
--
-- @tparam int _cn The client number of the player who changed the state
-- @tparam int _action The ID of the flag action
--
function DidStealFlagCheck:onFlagAction(_cn, _action)

  if (_action == LuaServerApi.FA_STEAL) then
    self.playersWhoStoleTheFlag[_cn] = true

  elseif (_action == LuaServerApi.FA_PICKUP) then
    if (self.playersWhoStoleTheFlag[_cn] ~= true) then
      Server.getInstance():getOutput():printTextTemplate(
        "GemaScoreManager/ScoreAttemptValidator/WarningFlagNotStolen",
        {},
        Server.getInstance():getPlayerList():getPlayerByCn(_cn)
      )
    end

  end

end


return DidStealFlagCheck
