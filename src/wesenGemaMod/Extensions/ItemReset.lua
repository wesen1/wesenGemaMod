---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local PlayerItemRespawnManager = require "Extensions.ItemReset.PlayerItemRespawnManager"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"
local Server = require "AC-LuaServer.Core.Server"

---
-- Resets the pickups per Player per score attempt.
--
-- @type ItemReset
--
local ItemReset = BaseExtension:extend()
ItemReset:implement(ServerEventListener)

---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
ItemReset.serverEventListeners = {
  onPlayerSpawn = "onPlayerSpawn",
  onPlayerItemPickupAfter = "onPlayerItemPickupAfter"
}

---
-- The EventCallback for the "onPlayerAdded" event of the player list
--
-- @tfield EventCallback onPlayerAddedEventCallback
--
ItemReset.onPlayerAddedEventCallback = nil

---
-- The EventCallback for the "onPlayerRemoved" event of the player list
--
-- @tfield EventCallback onPlayerRemovedEventCallback
--
ItemReset.onPlayerRemovedEventCallback = nil

---
-- The EventCallback for the "onGameModeStaysEnabledAfterGameChange" event of the GameHandler
--
-- @tfield EventCallback onGameModeStaysEnabledAfterGameChangeEventCallback
--
ItemReset.onGameModeStaysEnabledAfterGameChangeEventCallback = nil

---
-- The PlayerItemRespawnManager's for the currently connected Player's
--
-- @tfield PlayerItemRespawnManager[] playerItemRespawnManagers
--
ItemReset.playerItemRespawnManagers = nil


---
-- ItemReset constructor.
--
function ItemReset:new()
  self.super.new(self, "ItemReset", "GemaGameMode")

  self.onPlayerAddedEventCallback = EventCallback({ object = self, methodName = "onPlayerAdded"})
  self.onPlayerRemovedEventCallback = EventCallback({ object = self, methodName = "onPlayerRemoved"})
  self.onGameModeStaysEnabledAfterGameChangeEventCallback = EventCallback({ object = self, methodName = "onGameModeStaysEnabledAfterGameChange"})

  self.playerItemRespawnManagers = {}
end


-- Protected Methods

---
-- Initializes the event listeners.
--
function ItemReset:initialize()

  self:registerAllServerEventListeners()

  local playerList = Server.getInstance():getPlayerList()
  playerList:on("onPlayerAdded", self.onPlayerAddedEventCallback)
  playerList:on("onPlayerRemoved", self.onPlayerRemovedEventCallback)

  local gameModeManager = Server.getInstance():getExtensionManager():getExtensionByName("GameModeManager")
  gameModeManager:on("onGameModeStaysEnabledAfterGameChange", self.onGameModeStaysEnabledAfterGameChangeEventCallback)

  -- Add PlayerItemRespawnManager's for the already connected Player's
  for _, player in pairs(Server.getInstance():getPlayerList():getPlayers()) do
    self.playerItemRespawnManagers[player:getCn()] = PlayerItemRespawnManager(player)
  end

end

---
-- Removes the event listeners.
--
function ItemReset:terminate()

  self:unregisterAllServerEventListeners()

  local playerList = Server.getInstance():getPlayerList()
  playerList:off("onPlayerAdded", self.onPlayerAddedEventCallback)
  playerList:off("onPlayerRemoved", self.onPlayerRemovedEventCallback)

  local gameModeManager = Server.getInstance():getExtensionManager():getExtensionByName("GameModeManager")
  gameModeManager:off("onGameModeStaysEnabledAfterGameChange", self.onGameModeStaysEnabledAfterGameChangeEventCallback)

  -- Clear and remove all PlayerItemRespawnManager's
  for _, playerItemRespawnManager in pairs(self.playerItemRespawnManagers) do
    playerItemRespawnManager:cancelAllItemRespawns()
  end
  self.playerItemRespawnManagers = {}

end


-- Event Handlers

---
-- Event handler which is called after a player was added to the player list.
--
-- @tparam Player _player The player who was added
--
function ItemReset:onPlayerAdded(_player)
  self.playerItemRespawnManagers[_player:getCn()] = PlayerItemRespawnManager(_player)
end

---
-- Event handler which is called after a player was removed from the player list.
--
-- @tparam Player _player The player who was removed
--
function ItemReset:onPlayerRemoved(_player)
  self.playerItemRespawnManagers[_player:getCn()]:cancelAllItemRespawns()
  self.playerItemRespawnManagers[_player:getCn()] = nil
end

---
-- Event handler which is called when the game mode is not changed after a Game change.
--
function ItemReset:onGameModeStaysEnabledAfterGameChange()
  for _, playerItemRespawnManager in pairs(self.playerItemRespawnManagers) do
    playerItemRespawnManager:cancelAllItemRespawns()
  end
end

---
-- Event handler which is called after a Player spawned.
--
-- @tparam int _cn The client number of the Player who spawned
--
function ItemReset:onPlayerSpawn(_cn)
  self.playerItemRespawnManagers[_cn]:respawnAllItems()
end

---
-- Event handler that is called after a Player picked up an item.
--
-- @tparam int _cn The client number of the player who picked up the item
-- @tparam int _itemType The item type
-- @tparam int _itemId The item id
--
function ItemReset:onPlayerItemPickupAfter(_cn, _itemType, _itemId)

  -- Send a item spawn event to all Player's for which the item is currently visible
  local itemRespawnPlayerCns = {}
  for cn, playerItemRespawnManager in pairs(self.playerItemRespawnManagers) do
    if (cn ~= _cn and not playerItemRespawnManager:hasPendingRespawnForItem(_itemId)) then
      table.insert(itemRespawnPlayerCns, cn)
    end
  end

  LuaServerApi.spawnitem(_itemId, itemRespawnPlayerCns)

  -- Add a item respawn timer for the Player who picked up the item
  self.playerItemRespawnManagers[_cn]:addItemRespawnTimer(_itemType, _itemId)

end


return ItemReset
