---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require "CommandManager.BaseCommand"
local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local CommandList = require "CommandManager.CommandList"
local CommandParser = require "CommandManager.CommandParser"
local CommandExecutor = require "CommandManager.CommandExecutor"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Server = require "AC-LuaServer.Core.Server"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"
local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"

---
-- Manages executing commands when players say "!<command name> <parameters>".
--
-- @type CommandManager
--
local CommandManager = BaseExtension:extend()
CommandManager:implement(ServerEventListener)

---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
CommandManager.serverEventListeners = {
  onPlayerSayText = { methodName = "onPlayerSayText", priority = 5 }
}

---
-- The command list
--
-- @tfield CommandList commandList
--
CommandManager.commandList = nil

---
-- The command parser
--
-- @tfield CommandParser commandParser
--
CommandManager.commandParser = nil

---
-- The command executor
--
-- @tfield CommandExecutor commandExecutor
--
CommandManager.commandExecutor = nil


---
-- CommandManager constructor.
--
function CommandManager:new()
  self.super.new(self, "CommandManager", "GemaGameMode")
  self.commandList = CommandList()
  self.commandParser = CommandParser()
  self.commandExecutor = CommandExecutor()
end


-- Getters and Setters

---
-- Returns the command list.
--
-- @treturn CommandList The command list
--
function CommandManager:getCommandList()
  return self.commandList
end


-- Protected Methods

---
-- Initializes this extension.
--
function CommandManager:initialize()
  self:registerAllServerEventListeners()
end

---
-- Terminates this extension.
--
function CommandManager:terminate()
  self:unregisterAllServerEventListeners()
end

---
-- Adds a extension to this CommandManager.
--
-- @tparam BaseExtension _extension The extension to add
--
function CommandManager:addExtension(_extension)

  self.super.addExtension(self, _extension)

  if (_extension:is(BaseCommand)) then
    self:addCommand(_extension)
  end

end


-- Event Handlers

---
-- Event handler which is called when a player says text.
--
-- @tparam int _cn The client number of the player
-- @tparam string _text The text that the player sent
--
function CommandManager:onPlayerSayText(_cn, _text)

  if (self.commandParser:isCommand(_text)) then

    local player = Server.getInstance():getPlayerList():getPlayerByCn(_cn)

    LuaServerApi.logline(
      LuaServerApi.ACLOG_INFO,
      string.format(
        "[%s] %s used command: '%s'",
        player:getIp(), player:getName(), _text
      )
    )

    local status, exception = pcall(self.handleCommand, self, player, _text)
    if (not status) then
      if (exception.is and exception:is(TemplateException)) then
        Server.getInstance():getOutput():printException(exception, player)
      else
        error(exception)
      end
    end

    -- Block the normal player text output of the server
    return LuaServerApi.PLUGIN_BLOCK

  end

end


-- Private Methods

---
-- Handles a command input of a player.
--
-- @tparam Player _player The player who used a command
-- @tparam string _text The text that the player said
--
-- @raise * Error while parsing the command
-- * Error while executing the command
--
function CommandManager:handleCommand(_player, _text)

  self.commandParser:parseCommand(_text, self.commandList)

  local command = self.commandParser:getCommand()
  local arguments = self.commandParser:getArguments()
  self.commandExecutor:executeCommand(command, arguments, _player)

end

---
-- Adds a Command to this CommandManager.
--
-- @tparam BaseCommand _command The command to add
--
function CommandManager:addCommand(_command)
  self.commandList:addCommand(_command)
end


return CommandManager
