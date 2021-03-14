---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local MapScoreStorage = require "GemaScoreManager.MapScoreStorage"
local Object = require "classic"
local ScoreContextProvider = require "GemaScoreManager.ScoreContextProvider"
local Server = require "AC-LuaServer.Core.Server"

---
-- Manages saving of new added MapScore's to the MapScoreStorage.
--
-- @type MapScoreSaver
--
local MapScoreSaver = Object:extend()

---
-- The MapScoreStorage
--
-- @tfield MapScoreStorage mapScoreStorage
--
MapScoreSaver.mapScoreStorage = nil

---
-- The ID's of the weapons for which own MapTop's exist
--
-- @tfield int[] weaponIdsWithOwnMapTops
--
MapScoreSaver.weaponIdsWithOwnMapTops = nil

---
-- The last score contexts for which a "mapScoreAdded" or "hiddenMapScoreAdded" event was fired
--
-- @tfield int[] lastMapScoreAddedContexts
--
MapScoreSaver.lastMapScoreAddedContexts = nil

---
-- The EventCallbacks for the "mapScoreAdded" and "hiddenMapScoreAdded" events of the MapTop's
-- This list is in the format { <score context> = <EventCallback>, ... }
--
-- @tfield EventCallback[] onMapScoreAddedToMapTopEventCallbacks
--
MapScoreSaver.onMapScoreAddedToMapTopEventCallbacks = nil

---
-- The EventCallback for the "mapScoreProcessed" event of the MapTopManager
--
-- @tfield EventCallback onMapScoreProcessedEventCallback
--
MapScoreSaver.onMapScoreProcessedEventCallback = nil


---
-- MapScoreSaver constructor.
--
-- @tparam MapScoreStorage _mapScoreStorage The MapScoreStorage to use
-- @tparam ScoreContextProvider _scoreContextProvider The ScoreContextProvider to use to interpret score contexts
--
function MapScoreSaver:new(_mapScoreStorage, _scoreContextProvider)
  self.mapScoreStorage = _mapScoreStorage
  self.scoreContextProvider = _scoreContextProvider

  self.onMapScoreProcessedEventCallback = EventCallback({ object = self, methodName = "onMapScoreProcessed" })
end


---
-- Initializes the event listeners.
--
-- @tparam MapTopManager _mapTopManager The MapTopManager for whose events to listen
--
function MapScoreSaver:initialize(_mapTopManager)

  self.weaponIdsWithOwnMapTops = {}
  self.lastMapScoreAddedContexts = {}

  _mapTopManager:on("mapScoreProcessed", self.onMapScoreProcessedEventCallback)

  self.onMapScoreAddedToMapTopEventCallbacks = {}
  for context, mapTop in pairs(_mapTopManager:getMapTops()) do

    if (self.scoreContextProvider:isWeaponScoreContext(context)) then
      table.insert(self.weaponIdsWithOwnMapTops, self.scoreContextProvider:scoreContextToWeaponId(context))
    end

    self.onMapScoreAddedToMapTopEventCallbacks[context] = EventCallback({
        object = self,
        methodName = "onMapScoreAddedToMapTop",
        additionalParameters = { [1] = { context } }
    })

    mapTop:on("mapScoreAdded", self.onMapScoreAddedToMapTopEventCallbacks[context])
    mapTop:on("hiddenMapScoreAdded", self.onMapScoreAddedToMapTopEventCallbacks[context])
  end

end

---
-- Terminates the event listeners.
--
-- @tparam MapTopManager _mapTopManager The MapTopManager to remove event listeners from
--
function MapScoreSaver:terminate(_mapTopManager)

  for context, mapTop in pairs(_mapTopManager:getMapTops()) do
    mapTop:off("mapScoreAdded", self.onMapScoreAddedToMapTopEventCallbacks[context])
    mapTop:off("hiddenMapScoreAdded", self.onMapScoreAddedToMapTopEventCallbacks[context])
  end
  self.onMapScoreAddedToMapTopEventCallbacks = {}

  _mapTopManager:off("mapScoreProcessed", self.onMapScoreProcessedEventCallback)

end


-- Event Handlers

---
-- Event handler that is called when a MapScore was added to one of the MapTop's.
--
-- @tparam string _context The context of the MapTop to which the MapScore was added
--
function MapScoreSaver:onMapScoreAddedToMapTop(_context)
  table.insert(self.lastMapScoreAddedContexts, _context)
end

---
-- Event handler that is called when a MapScore was processed by the MapTopManager.
--
function MapScoreSaver:onMapScoreProcessed(_mapScore)
  if (#self.lastMapScoreAddedContexts > 0) then
    self:saveMapScore(_mapScore, self.lastMapScoreAddedContexts)
    self.lastMapScoreAddedContexts = {}
  end
end


-- Private Methods

---
-- Saves a given MapScore.
--
-- @tparam MapScore _newMapScore The MapScore to save
-- @tparam string[] _addedForContexts The score contexts for which the MapScore was added to the MapTop's
--
function MapScoreSaver:saveMapScore(_newMapScore, _addedForContexts)

  local wasAddedToMainMapTop = false
  local wasAddedToWeaponMapTop = false
  for _, context in ipairs(_addedForContexts) do
    if (context == ScoreContextProvider.CONTEXT_MAIN) then
      wasAddedToMainMapTop = true
    elseif (self.scoreContextProvider:isWeaponScoreContext(context)) then
      wasAddedToWeaponMapTop = true
    end
  end

  local mapName = Server.getInstance():getGameHandler():getCurrentGame():getMapName()
  local filterWeaponIds, filterMode

  if (wasAddedToWeaponMapTop) then
    -- The MapScore was added to a weapon specific MapTop, replace only the best
    -- personal MapScore for that weapon if one exists
    filterWeaponIds = { _newMapScore:getWeaponId() }
    filterMode = MapScoreStorage.SAVE_WEAPON_FILTER_MODE_MATCHES

  elseif (wasAddedToMainMapTop) then
    -- The MapScore was only added to the main MapTop, make sure to not overwrite slower personal MapScore's
    -- that are managed by weapon specific MapTop's
    filterWeaponIds = self.weaponIdsWithOwnMapTops
    filterMode = MapScoreStorage.SAVE_WEAPON_FILTER_MODE_NOT_MATCHES

  else
    -- The MapScore was neither added to the main MapTop nor to a weapon specific MapTop, ignore it
    return
  end

  self.mapScoreStorage:saveMapScore(_newMapScore, mapName, filterWeaponIds, filterMode)

end


return MapScoreSaver
