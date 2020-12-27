---
-- @author wesen
-- @copyright 2018-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseGameMode = require "AC-LuaServer.Extensions.GameModeManager.BaseGameMode"
local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local MapNameChecker = require("Map/MapNameChecker");
local MapTopHandler = require("Tops/MapTopHandler");
local Server = require "AC-LuaServer.Core.Server"
local StaticString = require("Output/StaticString");

---
-- Wrapper class for the gema mode.
-- TODO: Rename to GemaGameMode
-- @type GemaGameMode
--
local GemaGameMode = BaseGameMode:extend()

---
-- The EventCallback for the "onPlayerAdded" event of the player list
--
-- @tfield EventCallback onPlayerAddedEventCallback
--
GemaGameMode.onPlayerAddedEventCallback = nil

---
-- The map name checker
--
-- @tfield MapNameChecker mapNameChecker
--
GemaGameMode.mapNameChecker = nil

---
-- The map top handler
--
-- @tfield MapTopHandler mapTopHandler
--
GemaGameMode.mapTopHandler = nil


---
-- GemaGameMode constructor.
--
function GemaGameMode:new()

  self.super.new(self, "GemaGameMode", "Gema")

  self.onPlayerAddedEventCallback = EventCallback({ object = self, methodName = "onPlayerAdded"})
  self.mapNameChecker = MapNameChecker()
  self.mapTopHandler = MapTopHandler()

end


-- Getters and setters

---
-- Returns the map top handler.
--
-- @treturn MapTop The map top handler
--
function GemaGameMode:getMapTopHandler()
  return self.mapTopHandler
end


-- Public Methods

---
-- Returns whether this GameMode can be enabled for a specified Game.
--
-- @tparam Game _game The game to check
--
-- @treturn bool True if this GameMode can be enabled for the specified Game, false otherwise
--
function GemaGameMode:canBeEnabledForGame(_game)
  return (_game:getGameModeId() == GM_CTF and self.mapNameChecker:isGemaMapName(_game:getMapName()))
end

---
-- Loads the commands and generates the gema maprot.
--
function GemaGameMode:initialize(_gameModeManager)

  self.super.initialize(self, _gameModeManager)

  self.mapTopHandler:initialize()

  local playerList = Server.getInstance():getPlayerList()
  playerList:on("onPlayerAdded", self.onPlayerAddedEventCallback)

  LuaServerApi.setautoteam(false)

  local playerList = Server.getInstance():getPlayerList()
  for _, player in pairs(playerList:getPlayers()) do
    self:printServerInformation(player)
  end

end

---
-- Terminates this Extension.
--
function GemaGameMode:terminate()

  self.super.terminate(self)

  self.mapTopHandler:terminate()

  local playerList = Server.getInstance():getPlayerList()
  playerList:off("onPlayerAdded", self.onPlayerAddedEventCallback)

  LuaServerApi.setautoteam(true)
end


-- Event Handlers

---
-- Event handler which is called after a player was added to the player list.
--
-- @tparam Player _player The player who connected
-- @tparam int _newNumberOfConnectedPlayers The new total number of connected players
--
function GemaGameMode:onPlayerAdded(_player, _newNumberOfConnectedPlayers)
  if (_newNumberOfConnectedPlayers == 1) then
    LuaServerApi.setautoteam(false)
  end

  self:printServerInformation(_player)
end


-- Private Methods

---
-- Prints the map statistics and information about the commands to a player.
--
-- @tparam Player _player The player to print the server information to
--
function GemaGameMode:printServerInformation(_player)

  local commandList = self:getExtensionManager():getExtensionByName("CommandManager"):getCommandList()
  local output = Server.getInstance():getOutput()

  local cmdsCommand = commandList:getCommand(StaticString("cmdsCommandName"):getString())
  local rulesCommand = commandList:getCommand(StaticString("rulesCommandName"):getString())

  output:printTableTemplate(
    "TableTemplate/ServerInformation",
    { ["cmdsCommand"] = cmdsCommand, ["rulesCommand"] = rulesCommand },
    _player
  )

end


return GemaGameMode
