---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local GemaMapRotationGenerator = require "Extensions.GemaMapRotationManager.GemaMapRotationGenerator"
local MapRotationEntry = require "AC-LuaServer.Core.MapRotation.MapRotationEntry"
local Server = require "AC-LuaServer.Core.Server"
local StaticString = require "Output.StaticString"
local TmpUtil = require "TmpUtil.TmpUtil"

---
-- Manages the gema map rotation.
--
-- @type GemaMapRotationManager
--
local GemaMapRotationManager = BaseExtension:extend()

---
-- The map rot generator
--
-- @tfield GemaMapRotGenerator mapRotationGenerator
--
GemaMapRotationManager.mapRotationGenerator = nil

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
  self.mapRotationGenerator = GemaMapRotationGenerator()
  self.onGemaMapUploadedEventCallback = EventCallback({ object = self, methodName = "onGemaMapUploaded"})
  self.onGemaMapRemovedEventCallback = EventCallback({ object = self, methodName = "onGemaMapRemoved"})

end


-- Protected Methods

---
-- Initializes the event listeners and generates the initial gema map rotation.
--
function GemaMapRotationManager:initialize()

  --local gemaMapManager = Server.getInstance():getExtension("GemaMapManager")
  local gemaMapManager = TmpUtil.getServerExtensionByName("GemaMapManager")
  gemaMapManager:on("onGemaMapUploaded", self.onGemaMapUploadedEventCallback)
  gemaMapManager:on("onGemaMapRemoved", self.onGemaMapRemovedEventCallback)

  local mapRotation = Server.getInstance():getMapRotation()
  mapRotation:changeMapRotationConfigFile("config/maprot_gema.cfg")
  self.mapRotationGenerator:generateGemaMapRot(mapRotation, "packages/maps/servermaps/incoming")

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

  --local gemaMapManager = Server.getInstance():getExtension("GemaMapManager")
  local gemaMapManager = TmpUtil.getServerExtensionByName("GemaMapManager")
  gemaMapManager:off("onGemaMapUploaded", self.onGemaMapUploadedEventCallback)
  gemaMapManager:off("onGemaMapRemoved", self.onGemaMapRemovedEventCallback)

  local mapRotation = Server.getInstance():getMapRotation()
  mapRotation:changeMapRotationConfigFile("config/maprot.cfg")

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


return GemaMapRotationManager
