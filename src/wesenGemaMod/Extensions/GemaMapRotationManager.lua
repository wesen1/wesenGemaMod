---
-- @author wesen
-- @copyright 2020-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local MapRotationEntry = require "AC-LuaServer.Core.MapRotation.MapRotationEntry"
local Server = require "AC-LuaServer.Core.Server"
local StaticString = require "Output.StaticString"

---
-- Manages the gema map rotation.
--
-- @type GemaMapRotationManager
--
local GemaMapRotationManager = BaseExtension:extend()

---
-- The EventCallback for the "onGemaMapUploaded" event of the GemaMapManager
--
-- @tfield EventCallback onGemaMapUploadedEventCallback
--
GemaMapRotationManager.onGemaMapUploadedEventCallback = nil

---
-- The EventCallback for the "onGemaMapRemoved" event of the GemaMapManager
--
-- @tfield EventCallback onGemaMapRemovedEventCallback
--
GemaMapRotationManager.onGemaMapRemovedEventCallback = nil


---
-- GemaMapRotationManager constructor.
--
function GemaMapRotationManager:new()
  self.super.new(self, "GemaMapRotationManager", "GemaGameMode")
  self.onGemaMapUploadedEventCallback = EventCallback({ object = self, methodName = "onGemaMapUploaded"})
  self.onGemaMapRemovedEventCallback = EventCallback({ object = self, methodName = "onGemaMapRemoved"})
end


-- Protected Methods

---
-- Initializes the event listeners and generates the initial gema map rotation.
--
function GemaMapRotationManager:initialize()

  local gemaMapManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaMapManager")
  gemaMapManager:on("onGemaMapUploaded", self.onGemaMapUploadedEventCallback)
  gemaMapManager:on("onGemaMapRemoved", self.onGemaMapRemovedEventCallback)

  local mapRotation = Server.getInstance():getMapRotation()
  mapRotation:changeMapRotationConfigFile("config/maprot_gema.cfg", true)
  self:generateInitialGemaMapRot(mapRotation)

  local output = Server.getInstance():getOutput()
  output:printTextTemplate(
    "TextTemplate/InfoMessages/MapRot/MapRotLoaded",
    { ["mapRotType"] = StaticString("mapRotTypeGema"):getString() }
  )

end

---
-- Removes the event listeners and restores the regular map rotation.
--
function GemaMapRotationManager:terminate()

  local gemaMapManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaMapManager")
  gemaMapManager:off("onGemaMapUploaded", self.onGemaMapUploadedEventCallback)
  gemaMapManager:off("onGemaMapRemoved", self.onGemaMapRemovedEventCallback)

  local mapRotation = Server.getInstance():getMapRotation()
  mapRotation:changeMapRotationConfigFile("config/maprot.cfg", true)

  local output = Server.getInstance():getOutput()
  output:printTextTemplate(
    "TextTemplate/InfoMessages/MapRot/MapRotLoaded",
    { ["mapRotType"] = StaticString("mapRotTypeRegular"):getString() }
  )

end


-- Event Handlers

---
-- Method that is called after a gema map was uploaded.
--
-- @tparam string _mapName The name of the gema map that was uploaded
--
function GemaMapRotationManager:onGemaMapUploaded(_mapName)
  Server.getInstance():getMapRotation():appendEntry(MapRotationEntry(_mapName))
end

---
-- Method that is called after a gema map was removed.
--
-- @tparam string _mapName The name of the gema map that was removed
--
function GemaMapRotationManager:onGemaMapRemoved(_mapName)
  Server.getInstance():getMapRotation():removeEntriesForMap(_mapName)
end

---
-- Generates a gema map rotation from the existing gema server maps.
--
-- @tparam MapRotation _mapRotation The map rotation to which to add the gema map entries
--
function GemaMapRotationManager:generateInitialGemaMapRot(_mapRot)

  local gemaMapManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaMapManager")

  local mapRotationEntries = {}
  for _, mapName in ipairs(gemaMapManager:getGemaMapNames()) do
    table.insert(mapRotationEntries, MapRotationEntry(mapName))
  end

  _mapRot:setAllEntries(mapRotationEntries)

end


return GemaMapRotationManager
