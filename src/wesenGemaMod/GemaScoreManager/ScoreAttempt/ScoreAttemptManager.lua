---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local EventEmitter = require "AC-LuaServer.Core.Event.EventEmitter"
local Object = require "classic"
local ScoreAttemptCollection = require "GemaScoreManager.ScoreAttempt.ScoreAttemptCollection"
local ScoreAttemptStateUpdater = require "GemaScoreManager.ScoreAttempt.ScoreAttemptStateUpdater"
local ScoreAttemptValidator = require "GemaScoreManager.ScoreAttempt.ScoreAttemptValidator"

---
-- Manages the ScoreAttempt's of players.
--
-- @type ScoreAttemptManager
--
local ScoreAttemptManager = Object:extend()
ScoreAttemptManager:implement(EventEmitter)

---
-- The ScoreAttemptCollection
--
-- @tfield ScoreAttemptCollection scoreAttemptCollection
--
ScoreAttemptManager.scoreAttemptCollection = nil

---
-- The ScoreAttemptStateUpdater
--
-- @tfield ScoreAttemptStateUpdater scoreAttemptStateUpdater
--
ScoreAttemptManager.scoreAttemptStateUpdater = nil

---
-- The ScoreAttemptValidator
--
-- @tfield ScoreAttemptValidator scoreAttemptValidator
--
ScoreAttemptManager.scoreAttemptValidator = nil

---
-- The EventCallback for the "scoreAttemptFinished" event of the ScoreAttemptCollection
--
-- @tfield EventCallback onScoreAttemptFinishedEventCallback
--
ScoreAttemptManager.onScoreAttemptFinishedEventCallback = nil


---
-- ScoreAttemptManager constructor.
--
function ScoreAttemptManager:new()
  self.scoreAttemptCollection = ScoreAttemptCollection()
  self.scoreAttemptStateUpdater = ScoreAttemptStateUpdater(self.scoreAttemptCollection)
  self.scoreAttemptValidator = ScoreAttemptValidator()

  self.onScoreAttemptFinishedEventCallback = EventCallback({ object = self, methodName = "onScoreAttemptFinished" })

  -- EventEmitter
  self.eventCallbacks = {}
end


-- Getters and Setters

---
-- Returns the ScoreAttemptCollection.
--
-- @treturn ScoreAttemptCollection scoreAttemptCollection
--
function ScoreAttemptManager:getScoreAttemptCollection()
  return self.scoreAttemptCollection
end


-- Public Methods

---
-- Initializes this ScoreAttemptManager.
--
function ScoreAttemptManager:initialize()
  self.scoreAttemptCollection:clear()

  self.scoreAttemptValidator:initialize()
  self.scoreAttemptCollection:on("scoreAttemptFinished", self.onScoreAttemptFinishedEventCallback)
  self.scoreAttemptStateUpdater:initialize()
end

---
-- Terminates this ScoreAttemptManager.
--
function ScoreAttemptManager:terminate()
  self.scoreAttemptStateUpdater:terminate()
  self.scoreAttemptValidator:terminate()
  self.scoreAttemptCollection:off("scoreAttemptFinished", self.onScoreAttemptFinishedEventCallback)

  self.scoreAttemptCollection:clear()
end


-- Event Handlers

---
-- Event handler that is called when a ScoreAttempt was finished.
--
-- @tparam int _cn The client number of the player whose ScoreAttempt was finished
-- @tparam ScoreAttempt _scoreAttempt The player's finished ScoreAttempt
--
function ScoreAttemptManager:onScoreAttemptFinished(_cn, _scoreAttempt)

  local scoreAttemptNotValidReason = self.scoreAttemptValidator:getScoreAttemptNotValidReason(_cn, _scoreAttempt)
  if (scoreAttemptNotValidReason == nil) then
    self:emit("validScoreAttemptFinished", _cn, _scoreAttempt)
  else
    self:emit("invalidScoreAttemptFinished", _cn, _scoreAttempt, scoreAttemptNotValidReason)
  end

end


return ScoreAttemptManager
