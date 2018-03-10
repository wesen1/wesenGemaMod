---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("Commands/BaseCommand");
local CommandParser = require("CommandHandler/CommandParser");
local CommandPrinter = require("CommandHandler/CommandPrinter");
local Output = require("Outputs/Output");

---
-- @type HelpCommand Command !help - Prints help texts for each command.
--
local HelpCommand = {};

-- ColorsCommand inherits from BaseCommand
setmetatable(HelpCommand, {__index = BaseCommand});


---
-- HelpCommand constructor.
--
-- @tparam CommandLister _parentCommandLister The parent command lister
--
-- @treturn HelpCommand The HelpCommand instance
--
function HelpCommand:__construct(_parentCommandLister)

  local instance = BaseCommand:__construct(_parentCommandLister, "help", 0);
  setmetatable(instance, {__index = HelpCommand});

  instance:addAlias("man");
  instance:addArgument("cmd", true, "Command name");
  instance:setDescription("Shows a commands description and it's arguments");

  return instance;

end

---
-- Displays the help text for a command to the player.
--
-- @tparam int _cn The client number of the player who executed the command
-- @tparam string[] _args The list of arguments which were passed by the player
--
function HelpCommand:execute(_cn, _args)

  local inputCommand = _args[1];

  if (_args[1]:sub(1,1) ~= "!") then
    inputCommand = "!" .. inputCommand;
  end

  local command = self.parentCommandLister:getCommand(inputCommand);

  if (command) then
    CommandPrinter:printHelpText(command, _cn);
  else
    Output:print(Output:getColor("error") .. "Error: Unknown command '" .. inputCommand .. "'", _cn);
  end

end


return HelpCommand;
