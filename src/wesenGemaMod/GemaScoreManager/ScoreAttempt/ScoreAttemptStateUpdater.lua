---
-- @author wesen
-- @copyright 2020-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Object = require "classic"
local Server = require "AC-LuaServer.Core.Server"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"

---
-- Manages updating the states of the ScoreAttempt's of players.
--
-- @type ScoreAttemptStateUpdater
--
local ScoreAttemptStateUpdater = Object:extend()
ScoreAttemptStateUpdater:implement(ServerEventListener)

---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
ScoreAttemptStateUpdater.serverEventListeners = {

  -- ScoreAttempt start
  onPlayerSpawn = "onPlayerSpawn",

  -- ScoreAttempt modify
  onPlayerShoot = "onPlayerShoot",

  -- ScoreAttempt finish
  onFlagAction = "onFlagAction",

  -- ScoreAttempt cancel
  onPlayerDisconnect = "onPlayerDisconnect",
  onPlayerDeath = "onPlayerDeath",
  onPlayerTeamChange = "onPlayerTeamChange",
  onMapEnd = "onMapEnd"
}

---
-- The EventCallback for the "after_forcedeath" event of the LuaServerApi
--
-- @tfield EventCallback onAfterForceDeathEventCallback
--
ScoreAttemptStateUpdater.onAfterForceDeathEventCallback = nil

---
-- The EventCallback for the "onGameModeStaysEnabledAfterGameChange" event of the GameHandler
--
-- @tfield EventCallback onGameModeStaysEnabledAfterGameChangeEventCallback
--
ScoreAttemptStateUpdater.onGameModeStaysEnabledAfterGameChangeEventCallback = nil

---
-- The ScoreAttemptCollection
--
-- @tfield ScoreAttemptCollection scoreAttemptCollection
--
ScoreAttemptStateUpdater.scoreAttemptCollection = nil


---
-- ScoreAttemptStateUpdater constructor.
--
-- @tparam ScoreAttemptCollection _scoreAttemptCollection The ScoreAttemptCollection to use
--
function ScoreAttemptStateUpdater:new(_scoreAttemptCollection)
  self.scoreAttemptCollection = _scoreAttemptCollection
  self.onAfterForceDeathEventCallback = EventCallback({ object = self, methodName = "onPlayerDeath" })
  self.onGameModeStaysEnabledAfterGameChangeEventCallback = EventCallback({ object = self, methodName = "onGameModeStaysEnabledAfterGameChange" })
end


-- Public Methods

---
-- Initializes this ScoreAttemptStateUpdater.
--
function ScoreAttemptStateUpdater:initialize()
  self:registerAllServerEventListeners()
  LuaServerApi:on("after_forcedeath", self.onAfterForceDeathEventCallback)

  local gameModeManager = Server.getInstance():getExtensionManager():getExtensionByName("GameModeManager")
  gameModeManager:on("onGameModeStaysEnabledAfterGameChange", self.onGameModeStaysEnabledAfterGameChangeEventCallback)
end

---
-- Terminates this ScoreAttemptStateUpdater.
--
function ScoreAttemptStateUpdater:terminate()
  self:unregisterAllServerEventListeners()
  LuaServerApi:off("after_forcedeath", self.onAfterForceDeathEventCallback)

  local gameModeManager = Server.getInstance():getExtensionManager():getExtensionByName("GameModeManager")
  gameModeManager:off("onGameModeStaysEnabledAfterGameChange", self.onGameModeStaysEnabledAfterGameChangeEventCallback)
end


-- Event Handlers

---
-- Event handler which is called when a player spawns.
--
-- @tparam int _cn The client number of the player who spawned
--
function ScoreAttemptStateUpdater:onPlayerSpawn(_cn)
  self.scoreAttemptCollection:startScoreAttempt(_cn)
end

---
-- Event handler that is called when a player shoots.
--
-- @tparam int _cn The client number of the player who shot
-- @tparam int _weaponId The ID of the weapon with which the player shot
--
function ScoreAttemptStateUpdater:onPlayerShoot(_cn, _weaponId)
  self.scoreAttemptCollection:updateScoreAttemptWeaponIfRequired(_cn, _weaponId)
end

---
-- Event handler that is called when the state of the flag is changed.
--
-- @tparam int _cn The client number of the player who changed the state
-- @tparam int _action The ID of the flag action
--
function ScoreAttemptStateUpdater:onFlagAction(_cn, _action)
  if (_action == LuaServerApi.FA_SCORE) then
    self.scoreAttemptCollection:processFlagScore(_cn)
  end
end

---
-- Event handler that is called when a player disconnects.
--
-- @tparam int _cn The client number of the player who disconnected
--
function ScoreAttemptStateUpdater:onPlayerDisconnect(_cn)
  self.scoreAttemptCollection:cancelScoreAttempt(_cn, "Player disconnected")
end

---
-- Event handler that is called when a player dies (including /suicide).
--
-- @tparam int _cn The client number of the player who died
--
function ScoreAttemptStateUpdater:onPlayerDeath(_cn)
  self.scoreAttemptCollection:cancelScoreAttempt(_cn, "Player died")
end

---
-- Event handler that is called when a player changes teams (to spectator or enemy team).
--
-- @tparam int _cn The client number of the player who changed teams
--
function ScoreAttemptStateUpdater:onPlayerTeamChange(_cn)
  self.scoreAttemptCollection:cancelScoreAttempt(_cn, "Player changed teams")
end

---
-- Event handler which is called when the game mode is not changed after a Game change.
--
function ScoreAttemptStateUpdater:onGameModeStaysEnabledAfterGameChange()
  self.scoreAttemptCollection:cancelAllScoreAttempts("Game changed")
end

---
-- Event handler that is called when the current game ends (on intermission).
--
function ScoreAttemptStateUpdater:onMapEnd()
  self.scoreAttemptCollection:cancelAllScoreAttempts("Game ended")
end


return ScoreAttemptStateUpdater
