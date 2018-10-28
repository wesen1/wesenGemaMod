---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("CommandHandler/BaseCommand");

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
-- @tparam CommandList _parentCommandList The parent command list
--
-- @treturn RulesCommand The RulesCommand instance
--
function RulesCommand:__construct(_parentCommandList)

  local instance = BaseCommand(
    _parentCommandList,
    "!rules",
    0,
    nil,
    {},
    "Shows the gema rules"
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

  -- Gema rules
  self.output:print(self.output:getColor("rulesGemaTitle") .. "Gema rules:", _player);
  self.output:print(self.output:getColor("rulesGemaText") .. "1. The goal is to reach the flags and score as fast as possible.", _player);
  self.output:print(self.output:getColor("rulesGemaText") .. "2. Killing other players on purpose is not allowed.", _player);
  self.output:print(self.output:getColor("infoWarning") .. "You may only play on this server when you agree to follow the rules above.", _player);
  self.output:print(self.output:getColor("infoWarning") .. "Breaking the rules may result in kicks or bans.", _player);
  self.output:print(self.output:getColor("info") .. "Read the extended server information for additional server specific rules.", _player);

end


return RulesCommand;
