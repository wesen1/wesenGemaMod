---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("CommandHandler/BaseCommand");
local StaticString = require("Output/StaticString");
local TableTemplate = require("Output/Template/TableTemplate");

---
-- Command !rules.
-- Displays the gema rules to a player
-- RulesCommand inherits from BaseCommand
--
-- @type RulesCommand
--
local RulesCommand = setmetatable({}, {__index = BaseCommand});


---
-- RulesCommand constructor.
--
-- @treturn RulesCommand The RulesCommand instance
--
function RulesCommand:__construct()

  local instance = BaseCommand(
    StaticString("rulesCommandName"):getString(),
    0,
    nil,
    {},
    StaticString("rulesCommandDescription"):getString()
  );
  setmetatable(instance, {__index = RulesCommand});

  return instance;

end

getmetatable(RulesCommand).__call = RulesCommand.__construct;


-- Public Methods

---
-- Displays the gema rules to a player.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
function RulesCommand:execute(_player, _arguments)
  self.output:printTableTemplate(TableTemplate("Commands/RulesCommandRules"), _player);
end


return RulesCommand;
