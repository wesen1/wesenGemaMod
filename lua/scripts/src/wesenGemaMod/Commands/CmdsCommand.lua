---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

local BaseCommand = require("Commands/BaseCommand");

--
-- Command !cmds
--
-- Displays all available commands to a player.
--
local CmdsCommand = {};
setmetatable(CmdsCommand, {__index = BaseCommand});

function CmdsCommand:__construct(_parentCommandLister)

  local instance = BaseCommand:__construct(_parentCommandLister, "cmds", 0);
  setmetatable(instance, {__index = CmdsCommand});
  
  
  instance:addAlias("commands");
  instance:setDescription("Displays a list of all commands that a player can use.");
  
  return instance;

end


--
-- Displays an auto generated list of all commands.
--
-- @param int _cn      Client number of the player who executed the command
-- @param array _args  Additional arguments
--
function CmdsCommand:execute(_cn, _args)

  local commandPrinter = self.parentCommandLister:getParentCommandHandler():getCommandPrinter();
  commandPrinter:printCommandList(_cn, self.parentCommandLister);  

end


return CmdsCommand;
