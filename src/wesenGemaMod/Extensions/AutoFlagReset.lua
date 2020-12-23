---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"

---
-- Instantly resets flags to their spawn locations when players drop them.
--
-- @type AutoFlagReset
--
local AutoFlagReset = BaseExtension:extend()
AutoFlagReset:implement(ServerEventListener)

---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
AutoFlagReset.serverEventListeners = {
  onFlagAction = "onFlagAction"
}

---
-- AutoFlagReset constructor.
--
function AutoFlagReset:new()
  self.super.new(self, "AutoFlagReset", "GemaGameMode")
end


-- Protected Methods

---
-- Initializes the event listeners.
--
function AutoFlagReset:initialize()
  self:registerAllServerEventListeners()
end

---
-- Removes the event listeners.
--
function AutoFlagReset:terminate()
  self:unregisterAllServerEventListeners()
end


-- Event Handlers

---
-- Event handler that is called when the state of the flag is changed.
--
-- @tparam int _cn The client number of the player who changed the state
-- @tparam int _action The id of the flag action
-- @tparam int _flag The id of the flag whose state was changed
--
function AutoFlagReset:onFlagAction(_cn, _action, _flag)

  if (_action == LuaServerApi.FA_DROP or _action == LuaServerApi.FA_LOST) then
    LuaServerApi.flagaction(_cn, LuaServerApi.FA_RESET, _flag)
  end

end


return AutoFlagReset
