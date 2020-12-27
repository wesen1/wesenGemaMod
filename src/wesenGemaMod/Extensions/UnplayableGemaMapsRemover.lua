---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local MapNameChecker = require "Map.MapNameChecker"
local MapVote = require "AC-LuaServer.Core.VoteListener.Vote.MapVote"
local Server = require "AC-LuaServer.Core.Server"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"
local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"

---
-- Checks if voted and sent maps are playable and removes them if they are not.
--
-- @type UnplayableGemaMapsRemover
--
local UnplayableGemaMapsRemover = BaseExtension:extend()

---
-- The EventCallback for the "onPlayerFailedToCallVote" event of the vote listener
--
-- @tfield EventCallback onPlayerFailedToCallVoteEventCallback
--
UnplayableGemaMapsRemover.onPlayerFailedToCallVoteEventCallback = nil

---
-- The map name checker
--
-- @tfield MapNameChecker mapNameChecker
--
UnplayableGemaMapsRemover.mapNameChecker = nil


---
-- UnplayableGemaMapsRemover constructor.
--
function UnplayableGemaMapsRemover:new()
  self.super.new(self, "UnplayableGemaMapsRemover", "Server")
  self.onPlayerFailedToCallVoteEventCallback = EventCallback({ object = self, methodName = "onPlayerFailedToCallVote" })
  self.mapNameChecker = MapNameChecker()
end


-- Protected Methods

---
-- Initializes the event listeners.
--
function UnplayableGemaMapsRemover:initialize()
  self.target:getVoteListener():on("onPlayerFailedToCallVote", self.onPlayerFailedToCallVoteEventCallback)
end

---
-- Removes the event listeners.
--
function UnplayableGemaMapsRemover:terminate()
  self.target:getVoteListener():off("onPlayerFailedToCallVote", self.onPlayerFailedToCallVoteEventCallback)
end


-- Event Handlers

---
-- Method that is called after a Player vote could not be called.
--
-- @tparam Vote _vote The vote that was attempted to be called
-- @tparam int _voteError The vote error ID
--
function UnplayableGemaMapsRemover:onPlayerFailedToCallVote(_vote, _voteError)

  if (_vote:is(MapVote) and
      LuaServerApi.mapexists(_vote:getMapName()) and
      self.mapNameChecker:isGemaMapName(_vote:getMapName()) and
      _vote:getGameModeId() == LuaServerApi.GM_CTF and
      _voteError == LuaServerApi.VOTEE_INVALID
  ) then
    -- MapVote for an existing gema map in game mode CTF failed, which means the map is either broken or does not support the CTF game mode
    local player = self.target:getPlayerList():getPlayerByCn(_vote:getCallerCn())
    self:removeUnplayableMap(_vote:getMapName(), player)

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
function UnplayableGemaMapsRemover:removeUnplayableMap(_mapName, _player)

  local output = Server.getInstance():getOutput()
  local status, exception = pcall(LuaServerApi.removemap, LuaServerApi, _mapName)
  if (status == true) then
    output:printTextTemplate(
      "TextTemplate/InfoMessages/Maps/AutomaticMapDeletion", { ["mapName"] = _mapName }, _player
    )
  elseif (exception.is and exception:is(TemplateException)) then
    output:printException(exception, _player)
  else
    error(exception)
  end

end


return UnplayableGemaMapsRemover
