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
-- Restricts the number of connections with the same IP.
-- If more than x clients connect with the same IP then the newest one will be disconnected.
--
-- @type ConnectionAmountLimiter
--
local ConnectionAmountLimiter = BaseExtension:extend()
ConnectionAmountLimiter:implement(ServerEventListener)


---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
ConnectionAmountLimiter.serverEventListeners = {
  onPlayerConnect = "onPlayerConnect"
}

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
end


-- Protected Methods

---
-- Initializes the event listeners.
--
function ConnectionAmountLimiter:initialize()
  self:registerAllServerEventListeners()
end

---
-- Removes the event listeners.
--
function ConnectionAmountLimiter:terminate()
  self:unregisterAllServerEventListeners()
end


-- Event Handlers

---
-- Event handler which is called when a player connects.
--
-- @tparam int _cn The client number of the player who connected
--
function ConnectionAmountLimiter:onPlayerConnect(_cn)

  local playerList = self.target:getPlayerList()
  local numberOfConnectionsWithIp = self:countConnectionsWithIp(playerList, _player:getIp())
  if (numberOfConnectionsWithIp > self.maximumNumberOfConnectionsWithSameIp) then

    self.output:printTextTemplate(
      "TextTemplate/InfoMessages/Player/PlayerDisconnectTooManyConnections",
      { ["player"] = _player }
    )

    LuaServerApi.disconnect(_player:getCn(), LuaServerApi.DISC_NONE)

    -- TODO: Check if it is required to manually call this PlayerList event handler
    playerList:onPlayerDisconnectAfter(_player:getCn())
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

  -- TODO: Add PlayerList:getPlayers() to AC-LuaServer
  local numberOfConnections = 0
  for _, player in pairs(_playerList.players) do
    if (player:getIp() == _ip) then
      numberOfConnections = numberOfConnections + 1
    end
  end

  return numberOfConnections

end


return ConnectionAmountLimiter
