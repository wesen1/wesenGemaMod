---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local CommandLister = require("CommandHandler/CommandLister");
local CommandLoader = require("CommandHandler/CommandLoader");
local CommandParser = require("CommandHandler/CommandParser");
local CommandPrinter = require("CommandHandler/CommandPrinter");


---
-- @type CommandHandler Handles commands loading, parsing, listing and printing.
--
local CommandHandler = {};


---
-- The command lister
--
-- @tfield CommandLister commandLister
--
CommandHandler.commandLister = "";

---
-- The command loader
--
-- @tfield CommandLoader commandLoader
--
CommandHandler.commandLoader = "";

---
-- The command parser
--
-- @tfield CommandParser commandParser
--
CommandHandler.commandParser = "";

---
-- The command printer
--
-- @tfield CommandPrinter commandPrinter
CommandHandler.commandPrinter = "";

---
-- The parent gema mod
--
-- @tfield GemaMod parentGemaMod
--
CommandHandler.parentGemaMod = "";


---
-- CommandHandler constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn CommandHandler The CommandHandler instance
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


-- Getters and setters

---
-- Returns the command lister.
--
-- @treturn CommandLister The command lister
--
function CommandHandler:getCommandLister()
  return self.commandLister;
end

---
-- Sets the command lister.
--
-- @tparam CommandLister _commandLister The command lister
--
function CommandHandler:setCommandLister(_commandLister)
  self.commandLister = _commandLister;
end

---
-- Returns the command loader.
--
-- @treturn CommandLoader The command loader
--
function CommandHandler:getCommandLoader()
  return self.commandLoader;
end

---
-- Sets the command loader.
--
-- @tparam CommandLoader _commandLoader The command loader
--
function CommandHandler:setCommandLoader(_commandLoader)
  self.commandLoader = commandLoader;
end

---
-- Returns the command parser.
--
-- @treturn CommandParser The command parser
--
function CommandHandler:getCommandParser()
  return self.commandParser;
end

---
-- Sets the command parser.
--
-- @tparam CommandParser _commandParser The command parser
--
function CommandHandler:setCommandParser(_commandParser)
  self.commandParser = _commandParser;
end

---
-- Returns the command printer.
--
-- @treturn CommandPrinter The command printer
--
function CommandHandler:getCommandPrinter()
  return self.commandPrinter;
end

---
-- Sets the command printer.
--
-- @tparam CommandPrinter _commandPrinter The command printer
--
function CommandHandler:setCommandPrinter(_commandPrinter)
  self.commandPrinter = _commandPrinter;
end

---
-- Returns the parent gema mod.
--
-- @treturn GemaMod The parent gema mod
--
function CommandHandler:getParentGemaMod()
  return self.parentGemaMod;
end

---
-- Sets the parent gema mod.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
function CommandHandler:setParentGemaMod(_parentGemaMod)
  self.parentGemaMod = _parentGemaMod;
end


-- Class Methods

---
-- Returns the command that has the name or alias _commandName.
--
-- @tparam string _commandName The name or alias of the command
--
-- @treturn BaseCommand|bool The command or false if no command with that name or alias exists
--
function CommandHandler:getCommand(_commandName)
  return self.commandLister:getCommand(_commandName);
end

---
-- Loads all commands from the Commands directory and adds them to the command lister.
--
function CommandHandler:loadCommands()
  self.commandLoader:loadCommands(self.commandLister);
end


return CommandHandler;
