---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Map = require "ORM.Models.Map"
local MapNameChecker = require "Map.MapNameChecker"
local MapRecord = require "ORM.Models.MapRecord"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"
local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"

---
-- Provides methods to manage the maps that are stored on the server.
-- Also handles gema maps in a special way.
-- This is gema specific but still a Server extension because it must be active even when the GemaGameMode
-- is currently disabled.
--
-- @type GemaMapManager
--
local GemaMapManager = BaseExtension:extend()
GemaMapManager:implement(ServerEventListener)

---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
GemaMapManager.serverEventListeners = {
  onPlayerSendMap = "onPlayerSendMap"
}

---
-- The map name checker
--
-- @tfield MapNameChecker mapNameChecker
--
GemaMapManager.mapNameChecker = nil


---
-- GemaMapManager constructor.
--
function GemaMapManager:new()
  self.super.new(self, "GemaMapManager", "Server")
  self.mapNameChecker = MapNameChecker()
end


-- Protected Methods

---
-- Initializes the event listeners.
--
function GemaMapManager:initialize()
  self.super.initialize(self)
  self:registerAllServerEventListeners()
  LuaServerApi:on("beforeMapRemove", EventCallback({ object = self, methodName = "onBeforeMapRemove" }))
  LuaServerApi:on("mapRemoved", EventCallback({ object = self, methodName = "onMapRemoved" }))
end

---
-- Removes the event listeners.
--
function GemaMapManager:terminate()
  self.super.terminate(self)
  self:unregisterAllServerEventListeners()
end


-- Event Handlers

---
-- Event handler which is called when a player tries to send a map to the server.
--
-- @tparam string _mapName The map name
-- @tparam int _cn The client number of the player who sent the map
-- @tparam int _revision The map revision
-- @tparam int _mapSize The map size
-- @tparam int _cfgSize The cfg size
-- @tparam int _cgzSize The cgz size
-- @tparam int _uploadError The upload error
--
function GemaMapManager:onPlayerSendMap(_mapName, _cn, _revision, _mapSize, _cfgSize, _cgzSize, _uploadError)

  if (_uploadError == LuaServerApi.UE_NOERROR and self.mapNameChecker:isGemaMapName(_mapName)) then
    -- It's a gema map upload that was not rejected

    local player = self.target:getPlayerList():getPlayerByCn(_cn)
    Map:new({
      name = _mapName,
      uploaded_by = player:getId(),
      uploaded_at = os.time()
    }):save()

    self:emit("onGemaMapUploaded", _mapName)

  end

end

---
-- Removes a given map from the server.
-- Will also remove the map from the database if it is a gema map.
--
-- @tparam string _mapName The name of the map to remove
--
-- @raise Error when there are scores for the map that should be removed
--
function GemaMapManager:onBeforeMapRemove(_mapName)

  if (self.mapNameChecker:isGemaMapName(_mapName)) then
    -- It's a gema map
    local map = Map:get()
                   :filterByName(_mapName)
                   :findOne()
    if (map) then
      -- The map exists in the database
      if (self:mapScoresExistForMap(map)) then
        error(TemplateException(
          "TextTemplate/ExceptionMessages/MapRemover/MapRecordsExistForDeleteMap",
          { ["mapName"] = _mapName }
        ))
      else
        map:delete()
      end
    end
  end

end

---
-- Event handler that is called when a map was removed from the server.
--
-- @tparam string _mapName The name of the map that was removed
--
function GemaMapManager:onMapRemoved(_mapName)

  if (self.mapNameChecker:isGemaMapName(_mapName)) then
    self:emit("onGemaMapRemoved", _mapName)
  end

end


-- Private Methods

---
-- Returns whether there are map scores for a given map.
--
-- @tparam Map _map The map to check
--
-- @treturn bool True if there are map scores for the given map, false otherwise
--
function GemaMapManager:mapScoresExistForMap(_map)

  local mapRecord = MapRecord:get()
                             :filterByMapId(_map.id)
                             :findOne()

  return (mapRecord ~= nil)

end


return GemaMapManager
