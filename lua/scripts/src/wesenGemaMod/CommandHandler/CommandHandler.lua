---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- 

local CommandLister = require("CommandHandler/CommandLister");
local CommandLoader = require("CommandHandler/CommandLoader");
local CommandParser = require("CommandHandler/CommandParser");
local CommandPrinter = require("CommandHandler/CommandPrinter");


---
-- Command handler.
--
local CommandHandler = {};


CommandHandler.commandLister = "";

CommandHandler.commandLoader = "";

CommandHandler.commandParser = "";

CommandHandler.commandPrinter = "";

CommandHandler.parentGemaMod = "";

---
-- CommandHandler constructor.
-- 
function CommandHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = CommandHandler});
  
  instance.commandLister = CommandLister:__construct(instance);
  instance.commandLoader = CommandLoader:__construct(instance);
  instance.commandParser = CommandParser:__construct(instance);
  instance.commandPrinter = CommandPrinter:__construct(instance);
  instance.parentGemaMod = _parentGemaMod;
  
  return instance;

end


function CommandHandler:getParentGemaMod()
  return self.parentGemaMod;
end

function CommandHandler:getCommand(_commandName)
  return self.commandLister:getCommand(_commandName);
end

function CommandHandler:loadCommands()
  self.commandLoader:loadCommands(self.commandLister);
end

function CommandHandler:getCommandParser()
  return self.commandParser;
end

function CommandHandler:getCommandPrinter()
  return self.commandPrinter;
end


return CommandHandler;
