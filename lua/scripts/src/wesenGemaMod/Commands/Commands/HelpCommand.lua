---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

require("BaseCommand");
require("CommandParser");
require("CommandPrinter");
require("Output");

--
-- Command !maptop
--
Help = BaseCommand:__construct("help", 0);
Help:addAlias("man");
Help:addArgument("cmd", true, "Command name");
Help:addArgument("test", false, "Hello name");
Help:addArgument("helloing", false, "Good evening");
Help:setDescription("Shows a commands description and it's arguments");

function Help:execute(_cn, _args)

  local inputCommand = _args[1];
  local command = commandLister:getCommand("!" .. inputCommand);
  
  if (command) then  
    CommandPrinter:printHelpText(command, _cn);

  else
    Output:print(colorLoader:getColor("error") .. "Error: Unknown command '!" .. inputCommand .. "'", _cn);

  end
  
end

return Help;

