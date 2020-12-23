---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BasePlayerList = require "AC-LuaServer.Core.PlayerList.PlayerList"
local Object = require "classic"
local Player = require "Player.Player"

---
-- Stores a list of Player's and provides methods to add/remove entries from the list.
--
-- @type PlayerList
--
local PlayerList = BasePlayerList:extend()

---
-- The list of players
--
-- @tfield Player[] players
--
PlayerList.players = nil


-- Getters and Setters

---
-- Returns the array of Player's.
--
-- @treturn Player[] The array of Player's
--
function PlayerList:getPlayers()
  return self.players
end


-- Event Handlers

---
-- Event handler that is called when a player connects to the server.
--
-- @tparam int _cn The client number of the player who connected
--
function PlayerList:onPlayerConnect(_cn)

  self.super.onPlayerConnect(self, _cn)

  self.players[_cn] = Player(self.players[_cn])
  self.players[_cn]:savePlayer()

end

---
-- Event handler that is called when a player changes his name.
--
-- @tparam int _cn The client number of the player who changed his name
-- @tparam string _newName The new name of the player
--
-- @emits The "onPlayerNameChanged" event after the Player object was adjusted
--
function PlayerList:onPlayerNameChange(_cn, _newName)

  self.super.onPlayerNameChange(self, _cn, _newName)

  -- Must check whether the player object is set because it is possible that the player used a script
  -- to change his name multiple times in a row within a small time frame and got autokicked for spam
  local player = self:getPlayerByCn(_cn)
  if (player) then
    player:savePlayer()
  end

end


return PlayerList
