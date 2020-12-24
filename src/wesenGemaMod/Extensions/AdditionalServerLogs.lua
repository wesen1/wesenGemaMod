---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Server = require  "AC-LuaServer.Core.Server"
local ServerEventListener = require  "AC-LuaServer.Core.ServerEvent.ServerEventListener"

---
-- Adds some non default server log lines.
--
-- @type AdditionalServerLogs
--
local AdditionalServerLogs = BaseExtension:extend()
AdditionalServerLogs:implement(ServerEventListener)

---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
AdditionalServerLogs.serverEventListeners = {
  onPlayerSayText = { methodName = "onPlayerSayText", priority = 0 }
}


---
-- AdditionalServerLogs constructor.
--
function AdditionalServerLogs:new()
  self.super.new(self, "AdditionalServerLogs", "Server")
end


-- Protected Methods

---
-- Initializes this Extension.
--
function AdditionalServerLogs:initialize()
  self:registerAllServerEventListeners()
end

---
-- Terminates this Extension.
--
function AdditionalServerLogs:terminate()
  self:unregisterAllServerEventListeners()
end


-- Event Handlers

---
-- Event handler which is called when a player says text.
--
-- @tparam int _cn The client number of the player
-- @tparam string _text The text that the player sent
--
function AdditionalServerLogs:onPlayerSayText(_cn, _text)

  local player = Server.getInstance():getPlayerList():getPlayerByCn(_cn)

  LuaServerApi.logline(
    LuaServerApi.ACLOG_INFO,
    string.format(
      "[%s] %s says: '%s'",
      player:getIp(), player:getName(), _text
    )
  )

end


return AdditionalServerLogs
