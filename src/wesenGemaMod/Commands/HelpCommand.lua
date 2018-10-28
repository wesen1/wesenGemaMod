---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("CommandHandler/BaseCommand");
local CommandArgument = require("CommandHandler/CommandArgument");
local CommandHelpTextPrinter = require("CommandHandler/CommandPrinter/CommandHelpTextPrinter");
local Exception = require("Util/Exception");

---
-- Command !help.
-- Prints help texts for each command.
-- ColorsCommand inherits from BaseCommand
--
-- @type HelpCommand
--
local HelpCommand = setmetatable({}, {__index = BaseCommand});


---
-- The command help text printer
--
-- @tfield CommandHelpTextPrinter The command help text printer
--
HelpCommand.commandHelpTextPrinter = nil;


---
-- HelpCommand constructor.
--
-- @tparam CommandList _parentCommandList The parent command list
--
-- @treturn HelpCommand The HelpCommand instance
--
function HelpCommand:__construct(_parentCommandList)

  local commandNameArgument = CommandArgument(
    "commandName",
    false,
    "string",
    "cmd",
    "The command name"
  );

  local instance = BaseCommand(
    _parentCommandList,
    "!help",
    0,
    nil,
    { commandNameArgument },
    "Shows a commands description and it's arguments",
    { "!man" }
  );
  setmetatable(instance, {__index = HelpCommand});

  instance.commandHelpTextPrinter = CommandHelpTextPrinter(instance.output);

  return instance;

end

getmetatable(HelpCommand).__call = HelpCommand.__construct;


-- Public Methods

---
-- Displays the help text for a command to the player.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
-- @raise Error in case of unknown command
--
function HelpCommand:execute(_player, _arguments)

  local command = self.parentCommandList:getCommand(_arguments.commandName);
  if (command) then
    self.commandHelpTextPrinter:printHelpText(command, _player);
  else
    error(Exception("Unknown command '" .. _arguments.commandName .. "'"));
  end

end

---
-- Adjusts the input arguments.
--
-- @tparam String[] The list of arguments
--
-- @treturn String[] The updated list of arguments
--
function HelpCommand:adjustInputArguments(_arguments)

  local arguments = _arguments;

  if (arguments.commandName:sub(1,1) ~= "!") then
    arguments.commandName = "!" .. arguments.commandName;
  end

  return arguments;

end


return HelpCommand;
