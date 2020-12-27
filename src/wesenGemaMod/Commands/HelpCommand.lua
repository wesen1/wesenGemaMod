---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require "CommandManager.BaseCommand"
local CommandArgument = require "CommandManager.CommandArgument"
local StaticString = require "Output.StaticString"
local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"

---
-- Command !help.
-- Prints help texts for each command.
--
-- @type HelpCommand
--
local HelpCommand = BaseCommand:extend()

---
-- The command help text printer
--
-- @tfield CommandHelpTextPrinter The command help text printer
--
HelpCommand.commandHelpTextPrinter = nil


---
-- HelpCommand constructor.
--
function HelpCommand:new()

  local commandNameArgument = CommandArgument(
    StaticString("helpCommandCommandNameArgumentName"):getString(),
    false,
    "string",
    StaticString("helpCommandCommandNameArgumentShortName"):getString(),
    StaticString("helpCommandCommandNameArgumentDescription"):getString()
  )

  self.super.new(
    self,
    StaticString("helpCommandName"):getString(),
    0,
    nil,
    { commandNameArgument },
    StaticString("helpCommandDescription"):getString(),
    { StaticString("helpCommandAlias1"):getString() }
  )

end


-- Public Methods

---
-- Displays the help text for a command to the player.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
-- @raise Error in case of unknown command
--
function HelpCommand:execute(_player, _arguments)

  local command = self.parentCommandList:getCommand(_arguments.commandName)
  if (command) then
    self.output:printTableTemplate(
      "CommandManager/Commands/Help",
      { ["command"] = command },
      _player
    )

  else
    error(TemplateException(
      "CommandManager/Exceptions/UnknownCommand",
      { ["commandName"] = _arguments.commandName }
    ))
  end

end

---
-- Adjusts the input arguments.
--
-- @tparam String[] The list of arguments
--
-- @treturn String[] The updated list of arguments
--
function HelpCommand:adjustInputArguments(_arguments)

  local arguments = _arguments

  if (arguments.commandName:sub(1,1) ~= "!") then
    arguments.commandName = "!" .. arguments.commandName
  end

  return arguments

end


return HelpCommand
