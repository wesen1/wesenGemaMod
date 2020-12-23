---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local GemaMapRotationGenerator = require "MapRotation.GemaMapRotationGenerator"
local MapRotationEntry = require "AC-LuaServer.Core.MapRotation.MapRotationEntry"

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
-- GemaMapRotationManager constructor.
--
function GemaMapRotationManager:new()
  self.super.new(self, "GemaMapRotationManager", "GemaMode")
  self.mapRotationGenerator = GemaMapRotationGenerator()
  self.onGemaMapUploadedEventCallback = EventCallback({ object = self, methodName = "onGemaMapUploaded"})

end


-- Protected Methods

---
-- Initializes the event listeners and generates the initial gema map rotation.
--
function GemaMapRotationManager:initialize()

  -- TODO: Server must allow to fetch extension by name
  local gemaMapManager = Server.getInstance():getExtension("MapManager")
  gemaMapManager:on("onGemaMapUploaded", self.onGemaMapUploadedEventCallback)

  local mapRotation = Server.getInstance():getMapRotation()
  mapRotation:changeMapRotationConfigFile("config/maprot_gema.cfg")
  self.mapRotGenerator:generateGemaMapRot(mapRotation, "packages/maps/servermaps/incoming")

end

---
-- Removes the event listeners and restores the regular map rotation.
--
function GemaMapRotationManager:terminate()

  local gemaMapManager = Server.getInstance():getExtension("MapManager")
  gemaMapManager:off("onGemaMapUploaded", self.onGemaMapUploadedEventCallback)

  local mapRotation = Server.getInstance():getMapRotation()
  mapRotation:changeMapRotationConfigFile("config/maprot.cfg")

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


return GemaMapRotationManager
