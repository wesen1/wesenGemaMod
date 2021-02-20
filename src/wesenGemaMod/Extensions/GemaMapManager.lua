---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"
local dir = require "pl.dir"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Map = require "ORM.Models.Map"
local MapNameChecker = require "Map.MapNameChecker"
local MapRecord = require "ORM.Models.MapRecord"
local path = require "pl.path"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"
local tablex = require "pl.tablex"
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
  onPlayerSendMap = "onPlayerSendMap",
  onPlayerRemoveMap = "onPlayerRemoveMap"
}

---
-- The map name checker
--
-- @tfield MapNameChecker mapNameChecker
--
GemaMapManager.mapNameChecker = nil

---
-- The names of all gema maps that are currently available on this server
--
-- @tfield string[] gemaMapNames
--
GemaMapManager.gemaMapNames = nil


---
-- GemaMapManager constructor.
--
function GemaMapManager:new()
  self.super.new(self, "GemaMapManager", "Server")
  self.mapNameChecker = MapNameChecker()
  self.gemaMapNames = {}
end


-- Getters and Setters

---
-- Returns the total number of gema maps that are currently available on the server.
--
-- @treturn int The total number of gema maps
--
function GemaMapManager:getNumberOfGemaMaps()
  return #self.gemaMapNames
end

---
-- Returns the names of all gema maps that are currently available on this server.
--
-- @treturn string The names of all gema maps that are currently available on this server
--
function GemaMapManager:getGemaMapNames()
  return self.gemaMapNames
end


-- Protected Methods

---
-- Initializes the event listeners.
--
function GemaMapManager:initialize()
  self.super.initialize(self)
  self:registerAllServerEventListeners()
  LuaServerApi:on("before_removemap", EventCallback({ object = self, methodName = "onBeforeMapRemove" }))
  LuaServerApi:on("after_removemap", EventCallback({ object = self, methodName = "onMapRemoved" }))

  -- Count the initial number of gema maps
  self.gemaMapNames = {}
  for _, mapName in ipairs(LuaServerApi.getservermaps()) do
    if (self.mapNameChecker:isGemaMapName(mapName)) then
      table.insert(self.gemaMapNames, mapName)
    end
  end
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

    local map = Map:get()
                   :where():column("name"):equals(_mapName)
                   :findOne()

    if (map == nil) then
      -- Initial upload of the map
      local player = self.target:getPlayerList():getPlayerByCn(_cn)
      Map:new({
          name = _mapName,
          uploaded_by = player:getId(),
          uploaded_at = os.time()
      }):save()

      table.insert(self.gemaMapNames, _mapName)
      self:emit("onGemaMapUploaded", _mapName)

    else
      -- The map gets updated, backup the old version
      self:backupMap(_mapName)
    end

  end

end

---
-- Event handler that is called before a Player removes a map via /deleteservermap.
--
-- @tparam string _mapName The name of the map that should be removed
-- @tparam int _cn The client number of the player who tries to remove the map
-- @tparam int _removeError The remove error code for the map deletion
--
function GemaMapManager:onPlayerRemoveMap(_mapName, _cn, _removeError)

  if (_removeError == LuaServerApi.RE_NOERROR) then
    -- Server allows the player to delete the map
    local status, result = pcall(self.checkMapRemovalRequest, self, _mapName)
    if (status == false) then

      local exception = result
      if (exception.is and exception:is(TemplateException)) then
        local player = self.target:getPlayerList():getPlayerByCn(_cn)
        self.target:getOutput():printException(exception, player)
        return LuaServerApi.RE_NOPERMISSION

      elseif (exception.is and exception:is(Exception)) then
        error(exception:getMessage())
      else
        error(exception)
      end

    else
      self:doRemoveGemaMap(_mapName)
    end

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
  self:checkMapRemovalRequest(_mapName)
  self:doRemoveGemaMap(_mapName)
end

---
-- Event handler that is called when a map was removed from the server.
--
-- @tparam string _mapName The name of the map that was removed
--
function GemaMapManager:onMapRemoved(_mapName)

  if (self.mapNameChecker:isGemaMapName(_mapName)) then
    local gemaMapNameIndex = tablex.find(self.gemaMapNames, _mapName)
    if (gemaMapNameIndex ~= nil) then
      self.gemaMapNames = tablex.removevalues(self.gemaMapNames, gemaMapNameIndex, gemaMapNameIndex)
    end

    self:emit("onGemaMapRemoved", _mapName)
  end

end


-- Private Methods

---
-- Checks if a map removal request is valid.
--
-- @tparam string _mapName The name of the map that should be removed
--
-- @raise Error when the map removal request is not valid
--
function GemaMapManager:checkMapRemovalRequest(_mapName)

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
      end
    end
  end

end

---
-- Backs up and removes a gema map from the database.
--
-- @tparam string _mapName The name of the gema map to remove
--
function GemaMapManager:doRemoveGemaMap(_mapName)

  -- Backup the map
  self:backupMap(_mapName)

  -- Remove the map from the database
  Map:get()
     :filterByName(_mapName)
     :delete()

  -- Trigger the "onMapRemoved" handler
  self:onMapRemoved(_mapName)

end

---
-- Backs up a given map.
--
-- @tparam string _mapName The name of the map to back up
--
function GemaMapManager:backupMap(_mapName)

  -- Find the path to the map cgz file
  local mapPath = LuaServerApi.getmappath(_mapName)
  if (mapPath == nil) then
    mapPath = "packages/maps/servermaps/incoming/" .. _mapName .. ".cgz"
    if (not path.isfile(mapPath)) then
      return
    end
  end

  -- Make sure the backup directory exists
  local backupDirectory = "packages/map_backups"
  dir.makepath(backupDirectory)

  -- Find a unique name for the backup
  local mapNumber = 0
  local backupMapPath
  repeat
    mapNumber = mapNumber + 1
    backupMapPath = backupDirectory .. "/" .. _mapName .. ".cgz_" .. mapNumber
  until (not path.isfile(backupMapPath))

  -- Copy the cgz file to the backup directory
  dir.copyfile(mapPath, backupMapPath)

  -- Check if a cfg file exists for the map and copy it too to the backup directory
  local mapCfgPath = mapPath:sub(1, -4) .. "cfg"
  if (path.isfile(mapCfgPath)) then
    dir.copyfile(mapCfgPath, backupMapPath:sub(1, -6) .. "cfg_" .. mapNumber)
  end

end

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
