---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("Commands/BaseCommand");

---
-- Command !cmds.
-- Displays all available commands to a player
--
-- @type CmdsCommand
--
local CmdsCommand = {};

-- CmdsCommand inherits from BaseCommand
setmetatable(CmdsCommand, {__index = BaseCommand});


---
-- CmdsCommand constructor.
--
-- @tparam CommandLister _parentCommandLister The parent command lister
--
-- @treturn CmdsCommand The CmdsCommand instance
--
function CmdsCommand:__construct(_parentCommandLister)

  local instance = BaseCommand:__construct(_parentCommandLister, "cmds", 0);
  setmetatable(instance, {__index = CmdsCommand});

  instance:addAlias("commands");
  instance:setDescription("Displays a list of all commands that a player can use.");

  return instance;

end


---
-- Displays an auto generated list of all commands.
--
-- @tparam int _cn The client number of the player who executed the command
-- @tparam string[] _args The list of arguments which were passed by the player
--
function CmdsCommand:execute(_cn, _args)

  local commandPrinter = self.parentCommandLister:getParentCommandHandler():getCommandPrinter();
  commandPrinter:printCommandList(_cn, self.parentCommandLister);

end


return CmdsCommand;
