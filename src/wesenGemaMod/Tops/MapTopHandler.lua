---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventEmitter = require "AC-LuaServer.Core.Event.EventEmitter"
local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local MapTop = require("Tops/MapTop/MapTop");
local Object = require "classic"
local Server = require "AC-LuaServer.Core.Server"
local TmpUtil = require "TmpUtil.TmpUtil"

---
-- Handles the maptops.
--
-- @type MapTopHandler
--
local MapTopHandler = Object:extend()
MapTopHandler:implement(EventEmitter)

---
-- The EventCallback for the "onGameModeStaysEnabledAfterGameChange" event of the GameHandler
--
-- @tfield EventCallback onGameModeStaysEnabledAfterGameChangeEventCallback
--
MapTopHandler.onGameModeStaysEnabledAfterGameChangeEventCallback = nil

---
-- The list of map tops
--
-- @tfield MapTop[] mapTops
--
MapTopHandler.mapTops = nil;


---
-- MapTopHandler constructor.
--
function MapTopHandler:new()
  self.eventCallbacks = {}
  self.onGameModeStaysEnabledAfterGameChangeEventCallback = EventCallback({ object = self, methodName = "onGameModeStaysEnabledAfterGameChange"})
  self.mapTops = {}
end


-- Getters and Setters

---
-- Returns the list of maptops.
--
-- @treturn MapTop[] The list of maptops
--
function MapTopHandler:getMapTops()
  return self.mapTops;
end


-- Public Methods

---
-- Initializes the main maptop and the event listeners.
--
function MapTopHandler:initialize()

  self.mapTops["main"] = MapTop();

  local gameModeManager = TmpUtil.getServerExtensionByName("GameModeManager")
  gameModeManager:on("onGameModeStaysEnabledAfterGameChange", self.onGameModeStaysEnabledAfterGameChangeEventCallback)

  local currentGame = Server.getInstance():getGameHandler():getCurrentGame()
  self.mapTops["main"]:loadRecords(currentGame:getMapName())
  self:emit("onMapScoresForMapLoaded", currentGame:getMapName())

end

---
-- Removes the event listeners.
--
function MapTopHandler:terminate()

  local gameModeManager = TmpUtil.getServerExtensionByName("GameModeManager")
  gameModeManager:off("onGameModeStaysEnabledAfterGameChange", self.onGameModeStaysEnabledAfterGameChangeEventCallback)

end

---
-- Returns a maptop with a specific id from the list of maptops.
--
-- @tparam string _mapTopId The maptop id
--
function MapTopHandler:getMapTop(_mapTopId)
  return self.mapTops[_mapTopId];
end


-- Event Handlers

---
-- Event handler which is called when the game mode is not changed after a Game change.
--
-- @tparam Game _game The new current Game
--
function MapTopHandler:onGameModeStaysEnabledAfterGameChange(_game)
  self.mapTops["main"]:loadRecords(_game:getMapName())
  self:emit("onMapScoresForMapLoaded", _game:getMapName())
end


return MapTopHandler;
