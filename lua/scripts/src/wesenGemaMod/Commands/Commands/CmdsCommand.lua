---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

require("BaseCommand");
require("CommandPrinter");

--
-- Command !cmds
--
-- Displays all available commands to a player.
--
Cmds = BaseCommand:__construct("cmds", 0);
Cmds:addAlias("commands");
Cmds:setDescription("Displays a list of all commands that a player can use.");

--
-- Displays an auto generated list of all commands.
--
-- @param int _cn      Client number of the player who executed the command
-- @param array _args  Additional arguments
--
function Cmds:execute(_cn, _args)

  CommandPrinter:printCommandList(_cn);  
      
end


return Cmds;

