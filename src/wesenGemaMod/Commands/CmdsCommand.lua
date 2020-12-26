---
-- @author wesen
-- @copyright 2017-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require "CommandManager.BaseCommand"
local StaticString = require "Output.StaticString"

---
-- Command !cmds.
-- Displays all available commands to a player
--
-- @type CmdsCommand
--
local CmdsCommand = BaseCommand:extend()


---
-- CmdsCommand constructor.
--
function CmdsCommand:new()

  self.super.new(
    self,
    StaticString("cmdsCommandName"):getString(),
    0,
    nil,
    {},
    StaticString("cmdsCommandDescription"):getString(),
    { StaticString("cmdsCommandAlias1"):getString() }
  )

end


-- Public Methods

---
-- Displays an auto generated list of all commands.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
function CmdsCommand:execute(_player, _arguments)
  self.output:printTableTemplate(
    "CommandManager/Commands/ListCommands",
    { commandList = self.parentCommandList, maximumLevel = _player:getLevel() },
    _player
  )
end


return CmdsCommand
