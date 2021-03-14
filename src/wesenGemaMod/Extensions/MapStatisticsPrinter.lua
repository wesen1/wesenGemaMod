---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local ScoreContextProvider = require "GemaScoreManager.ScoreContextProvider"
local Server = require "AC-LuaServer.Core.Server"

---
-- Handles printing the statistics for gema maps to players.
--
-- @type MapStatisticsPrinter
--
local MapStatisticsPrinter = BaseExtension:extend()

---
-- The EventCallback for the "onPlayerAdded" event of the player list
--
-- @tfield EventCallback onPlayerAddedEventCallback
--
MapStatisticsPrinter.onPlayerAddedEventCallback = nil

---
-- The EventCallback for the "onGameModeStaysEnabledAfterGameChange" event of the GameHandler
--
-- @tfield EventCallback onGameModeStaysEnabledAfterGameChangeEventCallback
--
MapStatisticsPrinter.onGameModeStaysEnabledAfterGameChangeEventCallback = nil


---
-- MapStatisticsPrinter constructor.
--
function MapStatisticsPrinter:new()
  self.super.new(self, "MapStatisticsPrinter", "GemaGameMode")

  self.onPlayerAddedEventCallback = EventCallback({ object = self, methodName = "onPlayerAdded"})
  self.onGameModeStaysEnabledAfterGameChangeEventCallback = EventCallback({ object = self, methodName = "onGameModeStaysEnabledAfterGameChange"})
end


-- Protected Methods

---
-- Initializes this Extension.
--
function MapStatisticsPrinter:initialize()

  local playerList = Server.getInstance():getPlayerList()
  playerList:on("onPlayerAdded", self.onPlayerAddedEventCallback)

  local mapTopManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaScoreManager"):getMapTopManager()
  mapTopManager:on("mapScoresForMapLoaded", self.onGameModeStaysEnabledAfterGameChangeEventCallback)

  local currentGame = Server.getInstance():getGameHandler():getCurrentGame()
  if (mapTopManager:getMapTop(ScoreContextProvider.CONTEXT_MAIN):getMapName() == currentGame:getMapName()) then
    self:onGameModeStaysEnabledAfterGameChange()
  end

end

---
-- Terminates this Extension.
--
function MapStatisticsPrinter:terminate()

  local playerList = Server.getInstance():getPlayerList()
  playerList:off("onPlayerAdded", self.onPlayerAddedEventCallback)

  local mapTopManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaScoreManager"):getMapTopManager()
  mapTopManager:off("mapScoresForMapLoaded", self.onGameModeStaysEnabledAfterGameChangeEventCallback)

end


-- Event Handlers

---
-- Event handler which is called after a player was added to the player list.
--
-- @tparam Player _player The player who was added
--
function MapStatisticsPrinter:onPlayerAdded(_player)
  self:printMapStatistics(_player)
end

---
-- Event handler which is called when the game mode is not changed after a Game change.
--
function MapStatisticsPrinter:onGameModeStaysEnabledAfterGameChange()
  self:printMapStatistics()
end


-- Private Methods

---
-- Prints the map statistics to a player.
--
-- @tparam Player _player The player to print the map statistics to (optional)
--
function MapStatisticsPrinter:printMapStatistics(_player)

  local mapTopManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaScoreManager"):getMapTopManager()

  local output = Server.getInstance():getOutput()
  output:printTableTemplate(
    "Extensions/MapStatisticsPrinter/MapStatistics",
    { ["mapScoreList"] = mapTopManager:getMapTop(ScoreContextProvider.CONTEXT_MAIN):getScoreList() },
    _player
  )

end


return MapStatisticsPrinter
