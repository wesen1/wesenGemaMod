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
-- Manages the ScoreAttempt's of players.
--
-- @type ScoreAttemptManager
--
local ScoreAttemptManager = Object:extend()
ScoreAttemptManager:implement(ServerEventListener)

---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
ScoreAttemptManager.serverEventListeners = {

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
ScoreAttemptManager.onAfterForceDeathEventCallback = nil

---
-- The EventCallback for the "onGameModeStaysEnabledAfterGameChange" event of the GameHandler
--
-- @tfield EventCallback onGameModeStaysEnabledAfterGameChangeEventCallback
--
ScoreAttemptManager.onGameModeStaysEnabledAfterGameChangeEventCallback = nil

---
-- The ScoreAttemptCollection
--
-- @tfield ScoreAttemptCollection scoreAttemptCollection
--
ScoreAttemptManager.scoreAttemptCollection = nil


---
-- ScoreAttemptManager constructor.
--
-- @tparam ScoreAttemptCollection _scoreAttemptCollection The ScoreAttemptCollection to use
--
function ScoreAttemptManager:new(_scoreAttemptCollection)
  self.scoreAttemptCollection = _scoreAttemptCollection
  self.onAfterForceDeathEventCallback = EventCallback({ object = self, methodName = "onPlayerDeath" })
  self.onGameModeStaysEnabledAfterGameChangeEventCallback = EventCallback({ object = self, methodName = "onGameModeStaysEnabledAfterGameChange" })
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

  self:registerAllServerEventListeners()
  LuaServerApi:on("after_forcedeath", self.onAfterForceDeathEventCallback)

  local gameModeManager = Server.getInstance():getExtensionManager():getExtensionByName("GameModeManager")
  gameModeManager:on("onGameModeStaysEnabledAfterGameChange", self.onGameModeStaysEnabledAfterGameChangeEventCallback)
end

---
-- Terminates this ScoreAttemptManager.
--
function ScoreAttemptManager:terminate()
  self:unregisterAllServerEventListeners()
  LuaServerApi:off("after_forcedeath", self.onAfterForceDeathEventCallback)

  local gameModeManager = Server.getInstance():getExtensionManager():getExtensionByName("GameModeManager")
  gameModeManager:off("onGameModeStaysEnabledAfterGameChange", self.onGameModeStaysEnabledAfterGameChangeEventCallback)

  self.scoreAttemptCollection:clear()
end


-- Event Handlers

---
-- Event handler which is called when a player spawns.
--
-- @tparam int _cn The client number of the player who spawned
--
function ScoreAttemptManager:onPlayerSpawn(_cn)
  self.scoreAttemptCollection:startScoreAttempt(_cn)
end

---
-- Event handler that is called when a player shoots.
--
-- @tparam int _cn The client number of the player who shot
-- @tparam int _weaponId The ID of the weapon with which the player shot
--
function ScoreAttemptManager:onPlayerShoot(_cn, _weaponId)
  self.scoreAttemptCollection:updateScoreAttemptWeaponIfRequired(_cn, _weaponId)
end

---
-- Event handler that is called when the state of the flag is changed.
--
-- @tparam int _cn The client number of the player who changed the state
-- @tparam int _action The ID of the flag action
--
function ScoreAttemptManager:onFlagAction(_cn, _action)

  if (_action == LuaServerApi.FA_STEAL) then
    self.scoreAttemptCollection:markScoreAttemptFlagStolen(_cn)
  elseif (_action == LuaServerApi.FA_PICKUP) then
    self.scoreAttemptCollection:processFlagPickup(_cn)
  elseif (_action == LuaServerApi.FA_SCORE) then
    self.scoreAttemptCollection:processFlagScore(_cn)
  end

end

---
-- Event handler that is called when a player disconnects.
--
-- @tparam int _cn The client number of the player who disconnected
--
function ScoreAttemptManager:onPlayerDisconnect(_cn)
  self.scoreAttemptCollection:cancelScoreAttempt(_cn, "Player disconnected")
end

---
-- Event handler that is called when a player dies (including /suicide).
--
-- @tparam int _cn The client number of the player who died
--
function ScoreAttemptManager:onPlayerDeath(_cn)
  self.scoreAttemptCollection:cancelScoreAttempt(_cn, "Player died")
end

---
-- Event handler that is called when a player changes teams (to spectator or enemy team).
--
-- @tparam int _cn The client number of the player who changed teams
--
function ScoreAttemptManager:onPlayerTeamChange(_cn)
  self.scoreAttemptCollection:cancelScoreAttempt(_cn, "Player changed teams")
end

---
-- Event handler which is called when the game mode is not changed after a Game change.
--
function ScoreAttemptManager:onGameModeStaysEnabledAfterGameChange()
  self.scoreAttemptCollection:cancelAllScoreAttempts("Game changed")
end

---
-- Event handler that is called when the current game ends (on intermission).
--
function ScoreAttemptManager:onMapEnd()
  self.scoreAttemptCollection:cancelAllScoreAttempts("Game ended")
end


return ScoreAttemptManager
