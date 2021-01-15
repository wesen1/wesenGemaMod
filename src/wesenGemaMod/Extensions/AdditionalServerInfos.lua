---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local GemaGameMode = require "GemaMode"
local GeoipCountryDatabaseConnection = require "geoip.country"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Server = require  "AC-LuaServer.Core.Server"
local ServerEventListener = require  "AC-LuaServer.Core.ServerEvent.ServerEventListener"

---
-- Adds some server info messages that will be shown to all players.
--
-- @type AdditionalServerInfos
--
local AdditionalServerInfos = BaseExtension:extend()
AdditionalServerInfos:implement(ServerEventListener)

---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
AdditionalServerInfos.serverEventListeners = {
  onPlayerDisconnect = "onPlayerDisconnect"
}

---
-- The EventCallback for the "onPlayerAdded" event of the player list
--
-- @tfield EventCallback onPlayerAddedEventCallback
--
AdditionalServerInfos.onPlayerAddedEventCallback = nil

---
-- The EventCallback for the "onGameModeStaysEnabledAfterGameChange" event of the GameHandler
--
-- @tfield EventCallback onGameModeStaysEnabledAfterGameChangeEventCallback
--
AdditionalServerInfos.onGameModeStaysEnabledAfterGameChangeEventCallback = nil


---
-- AdditionalServerInfos constructor.
--
function AdditionalServerInfos:new()
  self.super.new(self, "AdditionalServerInfos", "Server")

  self.onPlayerAddedEventCallback = EventCallback({ object = self, methodName = "onPlayerAdded"})
  self.onGameModeStaysEnabledAfterGameChangeEventCallback = EventCallback({ object = self, methodName = "onGameModeStaysEnabledAfterGameChange"})
end


-- Protected Methods

---
-- Initializes this Extension.
--
function AdditionalServerInfos:initialize()
  self:registerAllServerEventListeners()

  local playerList = Server.getInstance():getPlayerList()
  playerList:on("onPlayerAdded", self.onPlayerAddedEventCallback)

  local gameModeManager = Server.getInstance():getExtensionManager():getExtensionByName("GameModeManager")
  gameModeManager:on("onGameModeStaysEnabledAfterGameChange", self.onGameModeStaysEnabledAfterGameChangeEventCallback)

end

---
-- Terminates this Extension.
--
function AdditionalServerInfos:terminate()
  self:unregisterAllServerEventListeners()

  local playerList = Server.getInstance():getPlayerList()
  playerList:off("onPlayerAdded", self.onPlayerAddedEventCallback)

  local gameModeManager = Server.getInstance():getExtensionManager():getExtensionByName("GameModeManager")
  gameModeManager:off("onGameModeStaysEnabledAfterGameChange", self.onGameModeStaysEnabledAfterGameChangeEventCallback)

end


-- Event Handlers

---
-- Event handler which is called when a player disconnects.
--
-- @tparam int _cn The client number of the player who disconnected
-- @tparam int _reason The disconnect reason
--
function AdditionalServerInfos:onPlayerDisconnect(_cn, _reason)

  if (_reason == LuaServerApi.DISC_BANREFUSE) then
    local player = Server.getInstance():getPlayerList():getPlayerByCn(_cn)
    local output = Server.getInstance():getOutput()
    output:printTextTemplate(
      "TextTemplate/InfoMessages/Player/PlayerDisconnectBanned", { ["playerName"] = player:getName() }
    )
  end

end

---
-- Event handler which is called after a player was added to the player list.
--
-- @tparam Player _player The player who was added
--
function AdditionalServerInfos:onPlayerAdded(_player, _numberOfPlayers)

  local output = self.target:getOutput()

  local gameModeManager = Server.getInstance():getExtensionManager():getExtensionByName("GameModeManager")
  local currentGameMode = gameModeManager:getActiveGameMode()
  if (not currentGameMode:is(GemaGameMode)) then
    output:printTextTemplate("TextTemplate/InfoMessages/GemaModeState/GemaModeNotEnabled", {}, _player)
  end

  local geoipCountryDatabaseConnection = GeoipCountryDatabaseConnection.open()
  local geoipCountryData = geoipCountryDatabaseConnection:query_by_addr(_player:getIp())
  geoipCountryDatabaseConnection:close()

  output:printTextTemplate("Extensions/AdditionalServerInfos/GeoIP", {
    player = _player,
    geoipCountryData = geoipCountryData
  })

end

---
-- Event handler which is called when the game mode is not changed after a Game change.
--
-- @tparam BaseGameMode _gameMode The current GameMode
--
function AdditionalServerInfos:onGameModeStaysEnabledAfterGameChange(_gameMode)

  if (not _gameMode:is(GemaGameMode)) then
    local output = self.target:getOutput()
    output:printTextTemplate("TextTemplate/InfoMessages/GemaModeState/GemaModeNotEnabled", {})
  end

end


return AdditionalServerInfos
