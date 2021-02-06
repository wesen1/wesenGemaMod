---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local ScoreAttemptValidationCheck = require "GemaScoreManager.ScoreAttempt.Validator.ScoreAttemptValidationCheck"
local Server = require "AC-LuaServer.Core.Server"
local StaticString = require "Output.StaticString"

---
-- Validation check that tracks whether the current loaded gema map still exists on the server.
--
-- @type MapExistsCheck
--
local MapExistsCheck = ScoreAttemptValidationCheck:extend()

---
-- Stores whether the current map was deleted
--
-- @tfield bool isCurrentMapDeleted
--
MapExistsCheck.isCurrentMapDeleted = nil

---
-- The EventCallback for the "onGemaMapRemoved" event of the GemaMapManager
--
-- @type EventCallback onGemaMapRemovedEventCallback
--
MapExistsCheck.onGemaMapRemovedEventCallback = nil

---
-- The EventCallback for the "onGameModeStaysEnabledAfterGameChange" event of the GameHandler
--
-- @tfield EventCallback onGameModeStaysEnabledAfterGameChangeEventCallback
--
MapExistsCheck.onGameModeStaysEnabledAfterGameChangeEventCallback = nil


---
-- MapExistsCheck constructor.
--
function MapExistsCheck:new()
  self.onGemaMapRemovedEventCallback = EventCallback({ object = self, methodName = "onGemaMapRemoved" })
  self.onGameModeStaysEnabledAfterGameChangeEventCallback = EventCallback({ object = self, methodName = "onGameModeStaysEnabledAfterGameChange" })
end


-- Public Methods

---
-- Initializes this ScoreAttemptValidationCheck.
--
function MapExistsCheck:initialize()

  self.isCurrentMapDeleted = false

  local gemaMapManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaMapManager")
  gemaMapManager:on("onGemaMapRemoved", self.onGemaMapRemovedEventCallback)

  local gameModeManager = Server.getInstance():getExtensionManager():getExtensionByName("GameModeManager")
  gameModeManager:on("onGameModeStaysEnabledAfterGameChange", self.onGameModeStaysEnabledAfterGameChangeEventCallback)

end

---
-- Terminates this ScoreAttemptValidationCheck.
--
function MapExistsCheck:terminate()

  local gemaMapManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaMapManager")
  gemaMapManager:off("onGemaMapRemoved", self.onGemaMapRemovedEventCallback)

  local gameModeManager = Server.getInstance():getExtensionManager():getExtensionByName("GameModeManager")
  gameModeManager:off("onGameModeStaysEnabledAfterGameChange", self.onGameModeStaysEnabledAfterGameChangeEventCallback)

end

---
-- Checks whether a given ScoreAttempt is valid.
-- Will return true if the current loaded map was not deleted from the server.
--
-- @tparam int _cn The client number of the player to which the ScoreAttempt belongs
-- @tparam ScoreAttempt _scoreAttempt The ScoreAttempt to validate
--
-- @treturn bool True if the ScoreAttempt is valid, false otherwise
--
function MapExistsCheck:isScoreAttemptValid(_cn, _scoreAttempt)
  return (not self.isCurrentMapDeleted)
end

---
-- Returns the error message that explains why a ScoreAttempt was not valid that
-- did not meet this check's conditions.
--
-- @treturn string The error message
--
function MapExistsCheck:getErrorMessage()
  return StaticString("mapExistsCheckErrorMessage")
end


-- Event Handlers

---
-- Event handler that is called when a gema map is removed from the server.
--
-- @tparam string _mapName The name of the map that was removed
--
function MapExistsCheck:onGemaMapRemoved(_mapName)
  local gameHandler = Server.getInstance():getGameHandler()
  if (_mapName == gameHandler:getCurrentGame():getMapName()) then
    self.isCurrentMapDeleted = true
  end
end

---
-- Event handler which is called when the game mode is not changed after a Game change.
--
function MapExistsCheck:onGameModeStaysEnabledAfterGameChange()
  self.isCurrentMapDeleted = false
end


return MapExistsCheck
