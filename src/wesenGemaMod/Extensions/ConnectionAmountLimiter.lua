---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"

---
-- Restricts the number of connections with the same IP.
-- If more than x clients connect with the same IP then the newest one will be disconnected.
--
-- @type ConnectionAmountLimiter
--
local ConnectionAmountLimiter = BaseExtension:extend()

---
-- The EventCallback for the "onPlayerAdded" event of the player list
--
-- @tfield EventCallback onPlayerAddedEventCallback
--
ConnectionAmountLimiter.onPlayerAddedEventCallback = nil

---
-- The maximum allowed number of connections with the same IP to the server
--
-- @tfield int maximumNumberOfConnectionsWithSameIp
--
ConnectionAmountLimiter.maximumNumberOfConnectionsWithSameIp = nil


---
-- ConnectionAmountLimiter constructor.
--
function ConnectionAmountLimiter:new(_maximumNumberOfConnectionsWithSameIp)
  self.super.new(self, "ConnectionAmountLimiter", "Server")
  self.maximumNumberOfConnectionsWithSameIp = _maximumNumberOfConnectionsWithSameIp
  self.onPlayerAddedEventCallback = EventCallback({ object = self, methodName = "onPlayerConnect"})
end


-- Protected Methods

---
-- Initializes the event listeners.
--
function ConnectionAmountLimiter:initialize()
  self.target:getPlayerList():on("onPlayerAdded", self.onPlayerAddedEventCallback)
end

---
-- Removes the event listeners.
--
function ConnectionAmountLimiter:terminate()
  self.target:getPlayerList():off("onPlayerAdded", self.onPlayerAddedEventCallback)
end


-- Event Handlers

---
-- Event handler which is called after a player was added to the player list.
--
-- @tparam Player _player The player who connected
--
function ConnectionAmountLimiter:onPlayerConnect(_player)

  local playerList = self.target:getPlayerList()
  local numberOfConnectionsWithIp = self:countConnectionsWithIp(playerList, _player:getIp())
  if (numberOfConnectionsWithIp > self.maximumNumberOfConnectionsWithSameIp) then

    self.target:getOutput():printTextTemplate(
      "TextTemplate/InfoMessages/Player/PlayerDisconnectTooManyConnections",
      { ["player"] = _player }
    )

    LuaServerApi.disconnect(_player:getCn(), LuaServerApi.DISC_NONE)

    -- TODO: playerList:removePlayer(_cn)
    -- TODO: LuaServerApi:on("playerManuallyDisconnected")
    playerList:onPlayerDisconnectAfter(_player:getCn())

    return LuaServerApi.PLUGIN_BLOCK

  end

end

-- Private Methods

---
-- Calculates and returns the number of connections with a given IP.
--
-- @tparam PlayerList _playerList The PlayerList to use to count the number of connections
-- @tparam string _ip The target IP
--
-- @treturn int The number of connections with the given IP
--
function ConnectionAmountLimiter:countConnectionsWithIp(_playerList, _ip)

  local numberOfConnections = 0
  for _, player in pairs(_playerList.players) do
    if (player:getIp() == _ip) then
      numberOfConnections = numberOfConnections + 1
    end
  end

  return numberOfConnections

end


return ConnectionAmountLimiter
