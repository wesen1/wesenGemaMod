---
-- @author wesen
-- @copyright 2017-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require "CommandManager.BaseCommand"
local StaticString = require("Output/StaticString")
local TemplateFactory = require("Output/Template/TemplateFactory")

---
-- Command !cmds.
-- Displays all available commands to a player
-- CmdsCommand inherits from BaseCommand
--
-- @type CmdsCommand
--
local CmdsCommand = BaseCommand:extend()


---
-- The cached CmdsCommandList Template
--
-- @tfield Template cmdsCommandListTemplate
--
CmdsCommand.cmdsCommandListTemplate = nil


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
  self.output:printTemplate(self:getCmdsCommandListTemplate(_player), _player)
end


-- Private Methods

---
-- Returns the CmdsCommandList Template.
-- The template will be rendered only when there is no cached template yet or when the players level
-- doesn't match the cached templates maximum level.
--
-- @tparam Player _player The player who executed the command
--
-- @treturn Template The CmdsCommandList Template
--
function CmdsCommand:getCmdsCommandListTemplate(_player)

  if (self.cmdsCommandListTemplate == nil or
      self.cmdsCommandListTemplate:getTemplateValues()["maximumLevel"] ~= _player:getLevel()) then

    self.cmdsCommandListTemplate = TemplateFactory.getInstance():getTemplate(
      "TableTemplate/Commands/CmdsCommandList",
      { commandList = self.parentCommandList, maximumLevel = _player:getLevel() }
    )
    self.cmdsCommandListTemplate:renderAsTable()

  end

  return self.cmdsCommandListTemplate

end


return CmdsCommand
