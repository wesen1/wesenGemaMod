---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("Commands/BaseCommand");
local Output = require("Outputs/Output");

---
-- Command !rules.
-- Displays the gema rules to a player
--
-- @type RulesCommand
--
local RulesCommand = {};

-- RulesCommand inherits from BaseCommand
setmetatable(RulesCommand, {__index = BaseCommand});


---
-- RulesCommand constructor.
--
-- @tparam CommandLister _parentCommandLister The parent command lister
--
-- @treturn RulesCommand The RulesCommand instance
--
function RulesCommand:__construct(_parentCommandLister)

  local instance = BaseCommand:__construct(_parentCommandLister, "rules", 0);
  setmetatable(instance, {__index = RulesCommand});

  instance:setDescription("Shows the gema rules");

  return instance;

end

---
-- Displays the gema rules to a player.
--
-- @tparam int _cn The client number of the player who executed the command
-- @tparam string[] _args The list of arguments which were passed by the player
--
function RulesCommand:execute(_cn, _args)

  -- Gema rules
  Output:print(Output:getColor("rulesGemaTitle") .. "Gema rules:", _cn);
  Output:print(Output:getColor("rulesGemaText") .. "1. The goal is to reach the flags and score as fast as possible.", _cn);
  Output:print(Output:getColor("rulesGemaText") .. "2. Killing other players on purpose is not allowed.", _cn);
  Output:print(Output:getColor("infoWarning") .. "You may only play on this server when you agree to follow the rules above.", _cn);
  Output:print(Output:getColor("infoWarning") .. "Breaking the rules may result in kicks or bans.", _cn);
  Output:print(Output:getColor("info") .. "Read the extended server information for additional server specific rules.", _cn);

end


return RulesCommand;
