---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Server = require "AC-LuaServer.Core.Server"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"

---
-- Forwards all voicecom messages to the players of all teams.
--
-- If you use voicecom your client will always send the sound first and the message afterwards.
-- This class assumes that the Server receives and processes the actions in that order.
--
-- @type GlobalVoicecom
--
local GlobalVoicecom = BaseExtension:extend()
GlobalVoicecom:implement(ServerEventListener)

---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
GlobalVoicecom.serverEventListeners = {
  onPlayerSayVoice = "onPlayerSayVoice",
  onPlayerSayText = "onPlayerSayText"
}

---
-- The EventCallback for the "onPlayerRemoved" event of the PlayerList
--
-- @tfield EventCallback onPlayerRemovedEventCallback
--
GlobalVoicecom.onPlayerRemovedEventCallback = nil

---
-- Stores the list of client numbers of the players who did send a voicecom sound
-- and for which a voicecom text is expected to be processed next
-- The list is in the format { <player_cn> = true, ... }
--
-- @tfield bool[] expectedVoicecomTexts
--
GlobalVoicecom.expectedVoicecomTexts = nil


---
-- GlobalVoicecom constructor.
--
function GlobalVoicecom:new()
  BaseExtension.new(self, "GlobalVoicecom", "Server")
  self.onPlayerRemovedEventCallback = EventCallback({ object = self, methodName = "onPlayerRemoved" })
  self.expectedVoicecomTexts = {}
end


-- Protected Methods

---
-- Initializes this extension.
--
function GlobalVoicecom:initialize()
  self:registerAllServerEventListeners()

  local playerList = Server.getInstance():getPlayerList()
  playerList:on("onPlayerRemoved", self.onPlayerRemovedEventCallback)
end

---
-- Terminates this extension.
--
function GlobalVoicecom:terminate()
  self:unregisterAllServerEventListeners()

  local playerList = Server.getInstance():getPlayerList()
  playerList:off("onPlayerRemoved", self.onPlayerRemovedEventCallback)
end


-- Event Handlers

---
-- Event handler that is called when a player sends a voicecom sound.
--
-- @tparam int _acn The client number of the actor player (the one who sent the voicecom sound)
-- @tparam int _sound The ID of the voicecom sound
--
-- @treturn int PLUGIN_BLOCK to prevent the regular voicecom sound processing
--
function GlobalVoicecom:onPlayerSayVoice(_acn, _sound)

  -- Always send the voicecom sound to all players
  LuaServerApi.voiceas(_sound, _acn, false)

  -- Remember that the next incoming player message should be the text that
  -- belongs to this voicecom sound
  self.expectedVoicecomTexts[_acn] = true

  -- Block further processing of the voicecom command
  return LuaServerApi.PLUGIN_BLOCK

end

---
-- Event handler that is called when a player says text.
--
-- @tparam int _acn The client number of the actor player (the one who said text)
-- @tparam string _message The message that the player sent
--
-- @treturn int|nil PLUGIN_BLOCK if this method handles printing the message, nil otherwise
--
function GlobalVoicecom:onPlayerSayText(_acn, _message)

  if (self.expectedVoicecomTexts[_acn]) then
    self.expectedVoicecomTexts[_acn] = nil

    local player = Server.getInstance():getPlayerList():getPlayerByCn(_acn)
    LuaServerApi.logline(
      LuaServerApi.ACLOG_INFO,
      string.format(
        "[%s] %s sent voicecom text: '%s'",
        player:getIp(), player:getName(), _message
      )
    )

    -- Show the messages that are related to voicecom sounds to all players
    LuaServerApi.sayas(_message, _acn, false, false)

    -- Block further processing of the player message
    return LuaServerApi.PLUGIN_BLOCK
  end

end

---
-- Event handler that is called when a Player is removed from the PlayerList.
--
-- @tparam Player _removedPlayer The Player who was removed
--
function GlobalVoicecom:onPlayerRemoved(_removedPlayer)
  self.expectedVoicecomTexts[_removedPlayer:getCn()] = nil
end


return GlobalVoicecom
