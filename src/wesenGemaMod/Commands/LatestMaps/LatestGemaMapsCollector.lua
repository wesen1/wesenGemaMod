---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local Map = require "ORM.Models.Map"
local Object = require "classic"
local Server = require "AC-LuaServer.Core.Server"
local tablex = require "pl.tablex"

---
-- Class that is responsible for collecting the 5 latest gema maps.
--
-- When it is initialized it loads the 5 latest gema maps from the database.
-- Then it listens for gemaMapUploaded and onGemaMapRemoved events to update the list of latest maps.
--
-- @type LatestGemaMapsCollector
--
local LatestGemaMapsCollector = Object:extend()

---
-- The maximum latest gema maps to store at a time
--
-- @tfield int limit
--
LatestGemaMapsCollector.limit = nil

---
-- The list of latest gema maps
--
-- @tfield Map[] latestGemaMaps
--
LatestGemaMapsCollector.latestGemaMaps = nil

---
-- The EventCallback for the "onGemaMapUploaded" event of the GemaMapManager
--
-- @type EventCallback onGemaMapUploadedEventCallback
--
LatestGemaMapsCollector.onGemaMapUploadedEventCallback = nil

---
-- The EventCallback for the "onGemaMapRemoved" event of the GemaMapManager
--
-- @type EventCallback onGemaMapRemovedEventCallback
--
LatestGemaMapsCollector.onGemaMapRemovedEventCallback = nil


---
-- LatestGemaMapsCollector constructor.
--
-- @tparam int _limit The maximum latest gema maps to store at a time
--
function LatestGemaMapsCollector:new(_limit)
  self.limit = _limit
  self.latestGemaMaps = {}
  self.onGemaMapUploadedEventListener = EventCallback({ object = self, methodName = "onGemaMapUploaded" })
  self.onGemaMapRemovedEventCallback = EventCallback({ object = self, methodName = "onGemaMapRemoved" })
end


-- Getters and Setters

---
-- Returns the current latest gema maps.
--
-- @treturn Map[] The latest gema maps
--
function LatestGemaMapsCollector:getLatestGemaMaps()
  return self.latestGemaMaps
end


-- Public Methods

---
-- Initializes this LatestGemaMapsCollector.
--
function LatestGemaMapsCollector:initialize()

  local gemaMapManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaMapManager")
  gemaMapManager:on("onGemaMapUploaded", self.onGemaMapUploadedEventListener)
  gemaMapManager:on("onGemaMapRemoved", self.onGemaMapRemovedEventCallback)

  self.latestGemaMaps = self:loadLatestGemaMaps(self.limit)

end

---
-- Terminates this LatestGemaMapsCollector.
--
function LatestGemaMapsCollector:terminate()

  local gemaMapManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaMapManager")
  gemaMapManager:off("onGemaMapUploaded", self.onGemaMapUploadedEventListener)
  gemaMapManager:off("onGemaMapRemoved", self.onGemaMapRemovedEventCallback)

  self.latestGemaMaps = {}

end


-- Event Handlers

---
-- Event handler that is called when a new gema map was successfully uploaded.
--
-- @tparam string _gemaMapName The name of the gema map that was uploaded
--
function LatestGemaMapsCollector:onGemaMapUploaded(_gemaMapName)

  local uploadedGemaMap = Map:get()
                             :filterByName(_gemaMapName)
                             :innerJoinPlayers()
                             :innerJoinNames()
                             :findOne()

  -- Insert the new uploaded gema map at the start of the list of latest gema maps
  table.insert(self.latestGemaMaps, 1, uploadedGemaMap)

  -- Clear the entry above the queue limit (if one exists)
  self.latestGemaMaps[self.limit + 1] = nil

end

---
-- Event handler that is called when a gema map was deleted.
--
-- @tparam string _gemaMapName The name of the gema map that was deleted
--
function LatestGemaMapsCollector:onGemaMapRemoved(_gemaMapName)

  local latestGemaMapWithNameIndex
  for i, latestGemaMap in ipairs(self.latestGemaMaps) do
    if (latestGemaMap.name == _gemaMapName) then
      latestGemaMapWithNameIndex = i
      break
    end
  end

  if (latestGemaMapWithNameIndex ~= nil) then
    -- Remove the map from the list of latest gema maps
    self.latestGemaMaps[latestGemaMapWithNameIndex] = nil
    self.latestGemaMaps = tablex.values(self.latestGemaMaps)

    -- Load the next latest gema map from the database
    local ignoreMapIds = {}
    for _, latestGemaMap in ipairs(self.latestGemaMaps) do
      table.insert(ignoreMapIds, latestGemaMap.id)
    end

    local nextLatestGemaMaps = self:loadLatestGemaMaps(1, ignoreMapIds)
    if (#nextLatestGemaMaps > 0) then
      tablex.insertvalues(self.latestGemaMaps, nextLatestGemaMaps)
    end

  end

end


-- Private Methods

---
-- Loads a given number of latest gema maps from the database.
--
-- @tparam int _numberOfMaps The number of latest maps to load
-- @tparam int[] _ignoredMapIds The ID's of the maps that should be ignored by the search
--
-- @treturn Map[] The loaded Map's
--
function LatestGemaMapsCollector:loadLatestGemaMaps(_numberOfMaps, _ignoredMapIds)

  --
  -- Left joining the players because some maps may not have a upload player
  -- The query assumes that the map IDs reflect the order in which the map were added
  --
  local latestGemaMapsQuery = Map:get()
                                 :leftJoinPlayers()
                                 :leftJoinNames()
                                 :orderBy("maps.id"):desc()
                                 :limit(_numberOfMaps)

  if (_ignoredMapIds) then
    latestGemaMapsQuery:where():NOT():column("maps.id"):isInList(_ignoredMapIds)
  end

  local latestGemaMapsCollection = latestGemaMapsQuery:find()

  local latestGemaMaps = {}
  for i = 1, latestGemaMapsCollection:count(), 1 do
    table.insert(latestGemaMaps, latestGemaMapsCollection[i])
  end

  return latestGemaMaps

end


return LatestGemaMapsCollector
