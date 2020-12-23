---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventEmitter = require "AC-LuaServer.Core.Event.EventEmitter"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Map = require "ORM.Models.Map"
local MapNameChecker = require "Map.MapNameChecker"
local MapRecord = require "ORM.Models.MapRecord"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"
local TemplateException = require "AC-LuaServer.Util.Exception.TemplateException"

---
-- Provides methods to manage the maps that are stored on the server.
-- Also handles gema maps in a special way.
-- This is gema specific but still a Server extension because it must be active even when the GemaGameMode
-- is currently disabled.
--
-- @type GemaMapManager
--
local GemaMapManager = MapManager:extend()
GemaMapManager:implement(EventEmitter)
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
-- @tparam MapNameChecker mapNameChecker
--
GemaMapManager.mapNameChecker = nil


---
-- GemaMapManager constructor.
--
function GemaMapManager:new()
  self.super.new(self)
  self.mapNameChecker = MapNameChecker()
end


-- Public Methods

---
-- Removes a given map from the server.
-- Will also remove the map from the database if it is a gema map.
--
-- @tparam string _mapName The name of the map to remove
--
-- @raise Error when there are scores for the map that should be removed
--
function GemaMapManager:removeMap(_mapName)

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

  self.super.removeMap(self, _mapName)

end


-- Protected Methods

---
-- Initializes the event listeners.
--
function GemaMapManager:initialize()
  self.super.initialize(self)
  self:registerAllServerEventListeners()
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

    -- TODO: Add GemaPlayerList to Server to replace PlayerList
    local player = self.target:getPlayerList():getPlayerByCn(_cn)
    Map:new({
      name = _mapName,
      uploaded_by = player:getId(),
      uploaded_at = os.time()
    }):save()

    self:emit("onGemaMapUploaded", _mapName)

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
