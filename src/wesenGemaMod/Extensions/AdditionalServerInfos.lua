---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local ServerEventListener = require  "AC-LuaServer.Core.ServerEvent.ServerEventListener"

---
-- Adds some server info messages that will be shown to all players.
--
-- @type AdditionalServerInfos
--
local AdditionalServerInfos = BaseExtension:extend()
AdditionalServerInfos:implement(ServerEventListener)

---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
AdditionalServerInfos.serverEventListeners = {
  onPlayerDisconnect = "onPlayerDisconnect"
}

---
-- AdditionalServerInfos constructor.
--
function AdditionalServerInfos:new()
  self.super.new(self, "AdditionalServerInfos", "Server")
end


-- Protected Methods

---
-- Initializes this Extension.
--
function AdditionalServerInfos:initialize()
  self:registerAllServerEventListeners()
end

---
-- Terminates this Extension.
--
function AdditionalServerInfos:terminate()
  self:unregisterAllServerEventListeners()
end


-- Event Handlers

---
-- Event handler which is called when a player disconnects.
--
-- @tparam int _cn The client number of the player who disconnected
-- @tparam int _reason The disconnect reason
--
function AdditionalServerInfos:onPlayerDisconnect(_cn, _reason)

  if (_reason == LuaServerApi.DISC_BANREFUSE) then
    local player = Server.getInstance():getPlayerList():getPlayerByCn(_cn)
    local output = Server.getInstance():getOutput()
    output:printTextTemplate(
      "TextTemplate/InfoMessages/Player/PlayerDisconnectBanned", { ["playerName"] = player:getName() }
    )
  end

end


return AdditionalServerInfos
