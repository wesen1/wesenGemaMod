---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local EventEmitter = require "AC-LuaServer.Core.Event.EventEmitter"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Server = require "AC-LuaServer.Core.Server"

---
-- Provides methods to manage the maps that are stored on the server.
-- TODO: Move this class to AC-LuaServer
--
-- @type MapManager
--
local MapManager = BaseExtension:extend()
MapManager:implement(EventEmitter)


---
-- MapManager constructor.
--
function MapManager:new()
  self.super.new(self, "MapManager", "Server")
end


-- Public Methods

---
-- Removes a given map from the server.
--
-- @tparam string _mapName The name of the map to remove
--
function MapManager:removeMap(_mapName)

  -- Remove the map from the map rotation
  local mapRotation = self.target:getMapRotation()
  mapRotation:removeEntriesForMap(_mapName)

  -- Remove the map cgz and cfg files
  LuaServerApi.removemap(_mapName)

end


return MapManager
