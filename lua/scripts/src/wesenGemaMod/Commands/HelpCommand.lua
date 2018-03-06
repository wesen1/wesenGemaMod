---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

local BaseCommand = require("Commands/BaseCommand");
local CommandParser = require("CommandHandler/CommandParser");
local CommandPrinter = require("CommandHandler/CommandPrinter");
local Output = require("Outputs/Output");

--
-- Command !maptop
--
local HelpCommand = {};
setmetatable(HelpCommand, {__index = BaseCommand});

function HelpCommand:__construct(_parentCommandLister)

  local instance = BaseCommand:__construct(_parentCommandLister, "help", 0);
  setmetatable(instance, {__index = HelpCommand});
  

  instance:addAlias("man");
  instance:addArgument("cmd", true, "Command name");
  instance:addArgument("test", false, "Hello name");
  instance:addArgument("helloing", false, "Good evening");
  instance:setDescription("Shows a commands description and it's arguments");
  
  return instance;

end


function HelpCommand:execute(_cn, _args)

  local inputCommand = _args[1];
  local command = self.parentCommandLister:getCommand("!" .. inputCommand);
  
  if (command) then  
    CommandPrinter:printHelpText(command, _cn);

  else
  
    local colorLoader = self.parentCommandLister:getParentCommandHandler():getParentGemaMod():getColorLoader();
  
    Output:print(colorLoader:getColor("error") .. "Error: Unknown command '!" .. inputCommand .. "'", _cn);

  end
  
end


return HelpCommand;
