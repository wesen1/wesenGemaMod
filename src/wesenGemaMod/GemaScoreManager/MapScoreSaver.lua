---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local Object = require "classic"
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
-- The last saved MapScore
--
-- @tfield MapScore lastSavedMapScore
--
MapScoreSaver.lastSavedMapScore = nil

---
-- The EventCallback for the "mapScoreAdded" event of the MapTop's
--
-- @tfield EventCallback onMapScoreAddedEventCallback
--
MapScoreSaver.onMapScoreAddedEventCallback = nil

---
-- The EventCallback for the "hiddenMapScoreAdded" event of the MapTop's
--
-- @tfield EventCallback onHiddenMapScoreAddedEventCallback
--
MapScoreSaver.onHiddenMapScoreAddedEventCallback = nil


---
-- MapScoreSaver constructor.
--
-- @tparam MapScoreStorage _mapScoreStorage The MapScoreStorage to use
--
function MapScoreSaver:new(_mapScoreStorage)
  self.mapScoreStorage = _mapScoreStorage

  self.onMapScoreAddedEventCallback = EventCallback({ object = self, methodName = "onMapScoreAdded" })
  self.onHiddenMapScoreAddedEventCallback = EventCallback({ object = self, methodName = "onHiddenMapScoreAdded" })
end


---
-- Initializes the event listeners.
--
-- @tparam MapTopManager _mapTopManager The MapTopManager for whose events to listen
--
function MapScoreSaver:initialize(_mapTopManager)

  for context, mapTop in pairs(_mapTopManager:getMapTops()) do
    mapTop:on("mapScoreAdded", self.onMapScoreAddedEventCallback)
    mapTop:on("hiddenMapScoreAdded", self.onHiddenMapScoreAddedEventCallback)
  end

end

---
-- Terminates the event listeners.
--
-- @tparam MapTopManager _mapTopManager The MapTopManager to remove event listeners from
--
function MapScoreSaver:terminate(_mapTopManager)

  for context, mapTop in pairs(_mapTopManager:getMapTops()) do
    mapTop:off("mapScoreAdded", self.onMapScoreAddedEventCallback)
    mapTop:off("hiddenMapScoreAdded", self.onHiddenMapScoreAddedEventCallback)
  end

end


-- Event Handlers

---
-- Event handler that is called when a MapScore was added to one of the MapTop's.
--
-- @tparam MapScore _newMapScore The MapScore that was added
--
function MapScoreSaver:onMapScoreAdded(_newMapScore)
  self:saveMapScore(_newMapScore)
end

---
-- Event handler that is called when a hidden MapScore was added to one of the MapTop's.
--
-- @tparam MapScore _newMapScore The hidden MapScore that was added
--
function MapScoreSaver:onHiddenMapScoreAdded(_newMapScore)
  self:saveMapScore(_newMapScore)
end


-- Private Methods

---
-- Saves a given MapScore.
--
-- @tparam MapScore _newMapScore The MapScore to save
--
function MapScoreSaver:saveMapScore(_newMapScore)

  if (self.lastSavedMapScore == _newMapScore) then
    return
  end

  local mapName = Server.getInstance():getGameHandler():getCurrentGame():getMapName()
  self.mapScoreStorage:saveMapScore(_newMapScore, mapName)
  self.lastSavedMapScore = _newMapScore

end


return MapScoreSaver
