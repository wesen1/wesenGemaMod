---
-- @author wesen
-- @copyright 2017-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventEmitter = require "AC-LuaServer.Core.Event.EventEmitter"
local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local MapScoreList = require "GemaScoreManager.MapScore.MapScoreList"
local MapTop = require "GemaScoreManager.MapScore.MapTop"
local ObjectUtils = require "Util.ObjectUtils"
local ScoreManager = require "GemaScoreManager.Score.ScoreManager"
local Server = require "AC-LuaServer.Core.Server"

---
-- Manages a list of MapTop's.
--
-- @type MapTopManager
--
local MapTopManager = ScoreManager:extend()
MapTopManager:implement(EventEmitter)

---
-- The MapScoreStorage that will be used to create MapTop instances
--
-- @tfield MapScoreStorage mapScoreStorage
--
MapTopManager.mapScoreStorage = nil

---
-- The mergeScoresByPlayerName configuration that will be passed to the created MapTop's
--
-- @tfield bool mergeScoresByPlayerName
--
MapTopManager.mergeScoresByPlayerName = nil

---
-- The EventCallback for the "onGameModeStaysEnabledAfterGameChange" event of the GameModeManager
--
-- @tfield EventCallback onGameModeStaysEnabledAfterGameChangeEventCallback
--
MapTopManager.onGameModeStaysEnabledAfterGameChangeEventCallback = nil


---
-- MapTopManager constructor.
--
-- @tparam MapScoreStorage _mapScoreStorage The MapScoreStorage to use
-- @tparam ScoreContextProvider _scoreContextProvider The ScoreContextProvider to use
-- @tparam string[] _contexts The contexts to create ScoreListManager's for
-- @tparam bool _mergeScoresByPlayerName Whether to merge MapScore's by player names
--
function MapTopManager:new(_mapScoreStorage, _scoreContextProvider, _contexts, _mergeScoresByPlayerName)

  self.mapScoreStorage = _mapScoreStorage
  self.mergeScoresByPlayerName = (_mergeScoresByPlayerName ~= false)
  ScoreManager.new(self, _scoreContextProvider, _contexts)

  self.onGameModeStaysEnabledAfterGameChangeEventCallback = EventCallback({ object = self, methodName = "onGameModeStaysEnabledAfterGameChange" })

  -- EventEmitter
  self.eventCallbacks = {}

end


-- Getters and Setters

---
-- Returns the list of MapTop's.
--
-- @treturn MapTop[] The list of MapTop's
--
function MapTopManager:getMapTops()
  return self:getScoreListManagers()
end


-- Public Methods

---
-- Initializes the MapTop's and the event listeners.
--
function MapTopManager:initialize()

  ScoreManager.initialize(self)

  local gameModeManager = Server.getInstance():getExtensionManager():getExtensionByName("GameModeManager")
  gameModeManager:on("onGameModeStaysEnabledAfterGameChange", self.onGameModeStaysEnabledAfterGameChangeEventCallback)

  local currentGame = Server.getInstance():getGameHandler():getCurrentGame()
  self:loadMapScores(currentGame:getMapName())

end

---
-- Removes the event listeners.
--
function MapTopManager:terminate()
  ScoreManager.terminate(self)

  local gameModeManager = Server.getInstance():getExtensionManager():getExtensionByName("GameModeManager")
  gameModeManager:off("onGameModeStaysEnabledAfterGameChange", self.onGameModeStaysEnabledAfterGameChangeEventCallback)
end


---
-- Adds a MapScore to all MapTop's.
--
-- @tparam MapScore _mapScore The MapScore to add
--
function MapTopManager:addMapScore(_mapScore)
  for _, mapTop in pairs(self:getMapTops()) do
    mapTop:addMapScoreIfBetterThanPreviousPlayerMapScore(ObjectUtils.clone(_mapScore))
  end

  self:emit("mapScoreProcessed", _mapScore)
end

---
-- Returns a MapTop for a given context.
--
-- @tparam string _context The MapTop context
--
-- @treturn MapTop|nil The MapTop for the given context
--
function MapTopManager:getMapTop(_context)
  return self:getScoreListManager(_context)
end


-- Protected Methods

---
-- Creates and returns a ScoreListManager instance.
--
-- @tparam string _context The context to create the ScoreListManager for
--
-- @treturn MapTop The created ScoreListManager instance
--
function MapTopManager:createScoreListManager(_context)
  local weaponId
  if (self.scoreContextProvider:isWeaponScoreContext(_context)) then
    weaponId = self.scoreContextProvider:scoreContextToWeaponId(_context)
  end

  return MapTop(MapScoreList(self.mergeScoresByPlayerName), self.mapScoreStorage, weaponId)
end


-- Event Handlers

---
-- Event handler which is called when the game mode is not changed after a Game change.
--
-- @tparam BaseGameMode _gameMode The current game mode
-- @tparam Game _game The new current Game
--
function MapTopManager:onGameModeStaysEnabledAfterGameChange(_gameMode, _game)
  self:loadMapScores(_game:getMapName())
end


-- Private Methods

---
-- Loads the MapScore's for a given map.
--
-- @tparam string _mapName The name of the map for which to load the corresponding MapScore's
--
function MapTopManager:loadMapScores(_mapName)
  for _, mapTop in pairs(self:getMapTops()) do
    mapTop:loadMapScores(_mapName)
  end

  self:emit("mapScoresForMapLoaded", _mapName)
end


return MapTopManager
