---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Object = require "classic"
local Timer = require "Extensions.ItemReset.Timer"

---
-- Manages respawning items (pickups) for a single Player.
--
-- @type PlayerItemRespawnManager
--
local PlayerItemRespawnManager = Object:extend()

---
-- The Player for which the item respawning is managed
--
-- @tfield Player player
--
PlayerItemRespawnManager.player = nil

---
-- The current item respawn timers
-- A timer will be started when the player picked up an item
-- This list is in the format { <cn> => Timer, ... }
--
-- @tfield Timer[] itemRespawnTimers
--
PlayerItemRespawnManager.itemRespawnTimers = nil


---
-- PlayerItemRespawnManager constructor.
--
-- @tparam Player _player The Player for which the item respawning is managed
--
function PlayerItemRespawnManager:new(_player)
  self.player = _player
  self.itemRespawnTimers = {}
end


-- Public Methods

---
-- Adds a item respawn Timer for a given item.
--
-- @tparam int _itemType The item type
-- @tparam int _itemId The item id
--
function PlayerItemRespawnManager:addItemRespawnTimer(_itemType, _itemId)

  local respawnTime = LuaServerApi.spawntime(_itemType)
  self.itemRespawnTimers[_itemId] = Timer(
    Timer.TYPE_ONCE,
    respawnTime,
    function()
      self:respawnItem(_itemId)
      self.itemRespawnTimers[_itemId] = nil
    end
  )

end

---
-- Returns whether this PlayerItemRespawnManager currently has a item respawn Timer for a given item ID.
--
-- @tparam int _itemId The item ID to check
--
-- @treturn bool True if this PlayerItemRespawnManager has a item respawn Timer for the item ID, false otherwise
--
function PlayerItemRespawnManager:hasPendingRespawnForItem(_itemId)
  return self.itemRespawnTimers[_itemId] ~= nil
end

---
-- Cancels all currently running item respawn Timer's.
--
function PlayerItemRespawnManager:cancelAllItemRespawns()
  for _, itemRespawnTimer in pairs(self.itemRespawnTimers) do
    itemRespawnTimer:cancel()
  end
end

---
-- Respawns all items for the Player for which there currently are respawn Timer's.
--
function PlayerItemRespawnManager:respawnAllItems()

  for itemId, itemRespawnTimer in pairs(self.itemRespawnTimers) do
    self:respawnItem(itemId)
    itemRespawnTimer:cancel()
  end

end


-- Private Methods

---
-- Respawns a given item for the Player whose item respawns are managed by this PlayerItemRespawnManager.
--
-- @tparam int _itemId The ID of the item to respawn
--
function PlayerItemRespawnManager:respawnItem(_itemId)
  LuaServerApi.spawnitem(_itemId, { self.player:getCn() })
end


return PlayerItemRespawnManager
