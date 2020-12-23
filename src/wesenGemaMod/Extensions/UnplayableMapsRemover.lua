---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local MapVote = require "AC-LuaServer.Core.VoteListener.Vote.MapVote"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"
local TemplateException = require "AC-LuaServer.Util.Exception.TemplateException"

---
-- Checks if voted and sent maps are playable and removes them if they are not.
--
-- @type UnplayableMapsRemover
--
local UnplayableMapsRemover = BaseExtension:extend()
UnplayableMapsRemover:implement(ServerEventListener)

---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
UnplayableMapsRemover.serverEventListeners = {
  onPlayerSendMap = "onPlayerSendMap"
}

---
-- The EventCallback for the "onPlayerFailedToCallVote" event of the vote listener
--
-- @tfield EventCallback onPlayerFailedToCallVoteEventCallback
--
UnplayableMapsRemover.onPlayerFailedToCallVoteEventCallback = nil


---
-- UnplayableMapsRemover constructor.
--
function UnplayableMapsRemover:new()
  self.super.new(self, "UnplayableMapsRemover", "Server")
  self.onPlayerFailedToCallVoteEventCallback = EventCallback({ object = self, methodName = "onPlayerFailedToCallVote" })
end


-- Protected Methods

---
-- Initializes the event listeners.
--
function UnplayableMapsRemover:initialize()
  self:registerAllServerEventListeners()
  self.target:getVoteListener():on("onPlayerFailedToCallVote", self.onPlayerFailedToCallVoteEventCallback)
end

---
-- Removes the event listeners.
--
function UnplayableMapsRemover:terminate()
  self:unregisterAllServerEventListeners()
  self.target:getVoteListener():off("onPlayerFailedToCallVote", self.onPlayerFailedToCallVoteEventCallback)
end


-- Event Handlers

---
-- Method that is called after a Player vote could not be called.
--
-- @tparam Vote _vote The vote that was attempted to be called
-- @tparam int _voteError The vote error ID
--
function UnplayableMapsRemover:onPlayerFailedToCallVote(_vote, _voteError)

  if (_vote.is(MapVote) and
      LuaServerApi.mapexists(_vote:getMapName()) and not LuaServerApi.mapisok(_vote:getMapName())
  ) then
    -- MapVote for an existing but unplayable map
    local player = self.target:getPlayerList():getPlayerByCn(_vote:getCallerCn())
    self:removeUnplayableMap(_vote:getMapName(), player)

    -- TODO: Check if this is forwarded to the vote event listener
    return LuaServerApi.PLUGIN_BLOCK
  end

end

---
-- Event handler that is called when a player tries to send a map to the server.
--
-- @tparam string _mapName The map name
-- @tparam int _cn The client number of the player who sent the map
--
function UnplayableMapsRemover:onPlayerSendMap(_mapName, _cn)

  if (not LuaServerApi.mapisok(_mapName)) then
    local player = self.target:getPlayerList():getPlayerByCn(_vote:getCallerCn())
    self:removeUnplayableMap(_mapName, player)

    -- TODO: Check if this is forwarded to the send map event listener
    return LuaServerApi.PLUGIN_BLOCK
  end

end


-- Private Methods

---
-- Removes a given unplayable map from the server.
--
-- @tparam string _mapName The name of the map to remove
-- @tparam Player _player The player to which to print the success/error messages
--
function UnplayableMapsRemover:removeUnplayableMap(_mapName, _player)

  local mapManager = self.target:getMapManager()
  local status, exception = pcall(mapManager.removeMap, mapManager, _mapName)
  if (status == true) then
    self.output:printTextTemplate(
      "TextTemplate/InfoMessages/Maps/AutomaticMapDeletion", { ["mapName"] = _mapName }, _player
    )
  elseif (exception.is and exception.is(TemplateException)) then
    self.output:printException(exception, _player)
  else
    error(exception)
  end

end


return UnplayableMapsRemover
