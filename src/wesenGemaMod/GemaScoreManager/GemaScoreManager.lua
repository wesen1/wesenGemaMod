---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local MapScore = require "GemaScoreManager.MapScore.MapScore"
local MapTopManager = require "GemaScoreManager.MapScore.MapTopManager"
local MapScoreSaver = require "GemaScoreManager.MapScoreSaver"
local MapScoreStorage = require "GemaScoreManager.MapScoreStorage"
local MapScorePointsProvider = require "GemaScoreManager.ServerScore.MapScorePointsProvider"
local ObjectUtils = require "Util.ObjectUtils"
local ScoreAttemptManager = require "GemaScoreManager.ScoreAttempt.ScoreAttemptManager"
local ScoreAttemptScoreOutput = require "GemaScoreManager.ScoreAttemptScoreOutput"
local Server = require "AC-LuaServer.Core.Server"
local ServerTopManager = require "GemaScoreManager.ServerScore.ServerTopManager"

---
-- Manages everything that is related to Player scores.
--
-- @type GemaScoreManager
--
local GemaScoreManager = BaseExtension:extend()

---
-- The ScoreAttemptManager
--
-- @tfield ScoreAttemptManager scoreAttemptManager
--
GemaScoreManager.scoreAttemptManager = nil

---
-- The MapTopManager
--
-- @tfield MapTopManager mapTopManager
--
GemaScoreManager.mapTopManager = nil

---
-- The MapScoreSaver
--
-- @tfield MapScoreSaver mapScoreSaver
--
GemaScoreManager.mapScoreSaver = nil

---
-- The ScoreAttemptScoreOutput
--
-- @tfield ScoreAttemptScoreOutput scoreAttemptScoreOutput
--
GemaScoreManager.scoreAttemptScoreOutput = nil

---
-- The ServerTopManager
--
-- @tfield ServerTopManager serverTopManager
--
GemaScoreManager.serverTopManager = nil

---
-- The EventCallback for the "validScoreAttemptFinished" event of the ScoreAttemptManager
--
-- @tfield EventCallback onValidScoreAttemptFinishedEventCallback
--
GemaScoreManager.onValidScoreAttemptFinishedEventCallback = nil

---
-- The EventCallback for the "invalidScoreAttemptFinished" event of the ScoreAttemptManager
--
-- @tfield EventCallback onInvalidScoreAttemptFinishedEventCallback
--
GemaScoreManager.onInvalidScoreAttemptFinishedEventCallback = nil

---
-- GemaScoreManager constructor.
--
-- @tparam mixed[] _mapTopManagerOptions The MapTopManager options
-- @tparam mixed[] _serverTopManagerOptions The ServerTopManager options
--
function GemaScoreManager:new(_mapTopManagerOptions, _serverTopManagerOptions)
  BaseExtension.new(self, "GemaScoreManager", "GemaGameMode")

  self.scoreAttemptManager = ScoreAttemptManager()

  local mapTopManagerOptions = _mapTopManagerOptions or {}
  local mapScoreStorage = MapScoreStorage()
  local mapTopContexts = mapTopManagerOptions["contexts"] or { "main" }
  local mergeMapScoresByPlayerName = mapTopManagerOptions["mergeScoresByPlayerName"]
  self.mapTopManager = MapTopManager(mapScoreStorage, mapTopContexts, mergeMapScoresByPlayerName)

  self.mapScoreSaver = MapScoreSaver(mapScoreStorage)
  self.scoreAttemptScoreOutput = ScoreAttemptScoreOutput()

  local serverTopManagerOptions = _serverTopManagerOptions or {}
  local serverTopContexts = serverTopManagerOptions["contexts"] or { "main" }
  local mergeServerScoresByPlayerName = serverTopManagerOptions["mergeScoresByPlayerName"]
  local mapScorePointsProvider = serverTopManagerOptions["mapScorePointsProvider"] or MapScorePointsProvider()
  self.serverTopManager = ServerTopManager(
    mapScoreStorage, serverTopContexts, mergeServerScoresByPlayerName, mapScorePointsProvider
  )

  self.onValidScoreAttemptFinishedEventCallback = EventCallback({ object = self, methodName = "onValidScoreAttemptFinished" })
  self.onInvalidScoreAttemptFinishedEventCallback = EventCallback({ object = self, methodName = "onInvalidScoreAttemptFinished" })

end


-- Getters and Setters

---
-- Returns the ScoreAttemptManager.
--
-- @treturn ScoreAttemptManager The ScoreAttemptManager
--
function GemaScoreManager:getScoreAttemptManager()
  return self.scoreAttemptManager
end

---
-- Returns the MapTopManager.
--
-- @treturn MapTopManager The MapTopManager
--
function GemaScoreManager:getMapTopManager()
  return self.mapTopManager
end

---
-- Returns the ServerTopManager.
--
-- @treturn ServerTopManager The ServerTopManager
--
function GemaScoreManager:getServerTopManager()
  return self.serverTopManager
end


-- Protected Methods

---
-- Initializes this extension.
--
function GemaScoreManager:initialize()

  self.scoreAttemptManager:on("validScoreAttemptFinished", self.onValidScoreAttemptFinishedEventCallback)
  self.scoreAttemptManager:on("invalidScoreAttemptFinished", self.onInvalidScoreAttemptFinishedEventCallback)
  self.scoreAttemptManager:initialize()

  self.mapTopManager:initialize()
  self.mapScoreSaver:initialize(self.mapTopManager)
  self.scoreAttemptScoreOutput:initialize(self)
  self.serverTopManager:initialize(self.mapTopManager)

end

---
-- Terminates this extension.
--
function GemaScoreManager:terminate()

  self.scoreAttemptManager:off("validScoreAttemptFinished", self.onValidScoreAttemptFinishedEventCallback)
  self.scoreAttemptManager:off("invalidScoreAttemptFinished", self.onInvalidScoreAttemptFinishedEventCallback)
  self.scoreAttemptManager:terminate()

  self.mapTopManager:terminate()
  self.mapScoreSaver:terminate(self.mapTopManager)
  self.scoreAttemptScoreOutput:terminate(self)
  self.serverTopManager:terminate(self.mapTopManager)

end


-- Event Handlers

---
-- Event handler that is called when a valid ScoreAttempt was finished.
--
-- @tparam int _cn The client number of the player whose ScoreAttempt was finished
-- @tparam ScoreAttempt _scoreAttempt The player's finished ScoreAttempt
--
function GemaScoreManager:onValidScoreAttemptFinished(_cn, _scoreAttempt)
  self.mapTopManager:addMapScore(
    self:generateMapScoreFromScoreAttempt(_cn, _scoreAttempt)
  )
end

---
-- Event handler that is called when an invalid  ScoreAttempt was finished.
--
-- @tparam int _cn The client number of the player whose ScoreAttempt was finished
-- @tparam ScoreAttempt _scoreAttempt The player's finished ScoreAttempt
-- @tparam string _scoreAttemptNotValidReason The reason why the ScoreAttempt is not valid
--
function GemaScoreManager:onInvalidScoreAttemptFinished(_cn, _scoreAttempt, _scoreAttemptNotValidReason)
  self:emit(
    "invalidScoreAttemptFinished",
    self:generateMapScoreFromScoreAttempt(_cn, _scoreAttempt),
    _scoreAttemptNotValidReason
  )
end


-- Private Methods

---
-- Generates and returns a MapScore from a given ScoreAttempt.
--
-- @tparam int _cn The client number of the player to which the ScoreAttempt belongs
-- @tparam ScoreAttempt _scoreAttempt The ScoreAttempt to generate a MapScore from
--
-- @treturn MapScore The generated MapScore
--
function GemaScoreManager:generateMapScoreFromScoreAttempt(_cn, _scoreAttempt)

  local player = Server.getInstance():getPlayerList():getPlayerByCn(_cn)
  return MapScore(
    ObjectUtils.clone(player), -- Clone the Player to prevent name changes from affecting the MapTop
    _scoreAttempt:getDuration(),
    _scoreAttempt:getWeaponId(),
    _scoreAttempt:getTeamId()
  )

end


return GemaScoreManager
