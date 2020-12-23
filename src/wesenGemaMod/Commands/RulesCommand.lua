---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require "CommandManager.BaseCommand"
local StaticString = require("Output/StaticString");

---
-- Command !rules.
-- Displays the gema rules to a player
-- RulesCommand inherits from BaseCommand
--
-- @type RulesCommand
--
local RulesCommand = BaseCommand:extend()


---
-- RulesCommand constructor.
--
function RulesCommand:new()

  self.super.new(
    self,
    StaticString("rulesCommandName"):getString(),
    0,
    nil,
    {},
    StaticString("rulesCommandDescription"):getString()
  )

end


-- Public Methods

---
-- Displays the gema rules to a player.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
function RulesCommand:execute(_player, _arguments)
  self.output:printTableTemplate("TableTemplate/Commands/RulesCommandRules", _player);
end


return RulesCommand;
