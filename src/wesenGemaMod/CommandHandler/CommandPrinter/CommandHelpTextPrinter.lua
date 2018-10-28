---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ArgumentPrinter = require("CommandHandler/CommandPrinter/ArgumentPrinter");
local CommandPrinter = require("CommandHandler/CommandPrinter/CommandPrinter");

---
-- Displays the help texts of commands.
--
-- @type CommandHelpTextPrinter
--
local CommandHelpTextPrinter = setmetatable({}, {});


---
-- The argument printer
--
-- @tfield ArgumentPrinter argumentPrinter
--
CommandHelpTextPrinter.argumentPrinter = nil;

---
-- The command printer
--
-- @tfield CommandPrinter commandPrinter
--
CommandHelpTextPrinter.commandPrinter = nil;

---
-- The output
--
-- @tfield Output output
--
CommandHelpTextPrinter.output = nil;


---
-- CommandHelpTextPrinter constructor.
--
-- @tparam Output output The output that can be used by this CommandHelpTextPrinter
--
-- @treturn CommandHelpTextPrinter The CommandHelpTextPrinter instance
--
function CommandHelpTextPrinter:__construct(_output)

  local instance = setmetatable({}, {__index = CommandHelpTextPrinter});

  instance.argumentPrinter = ArgumentPrinter(_output);
  instance.commandPrinter = CommandPrinter(_output);
  instance.output = _output;

  return instance;

end

getmetatable(CommandHelpTextPrinter).__call = CommandHelpTextPrinter.__construct;


-- Public Methods

---
-- Prints the help text of a command.
--
-- @tparam BaseCommand _command The command
-- @tparam Player _player The player to which the help text will be printed
--
function CommandHelpTextPrinter:printHelpText(_command, _player)

  local rows = {
    [1] = {
      self.output:getColor("helpTitle") .. "Usage ",
      ": " .. self.commandPrinter:generateCommandString(_command, true)
    },
    [2] = {
      self.output:getColor("helpTitle") .. "Description ",
      ": " .. self.output:getColor("helpDescription") .. _command:getDescription()
    },
    [3] = {
      self.output:getColor("helpTitle") .. "Required Level ",
      ": " .. self.output:getColor("helpLevel") .. self.output:getPlayerLevelName(_command:getRequiredLevel())
    }
  }

  local commandHasArguments = _command:getNumberOfArguments() > 0;
  if (commandHasArguments) then

    rows[4] = {
      self.output:getColor("helpTitle") .. "Arguments",
      self:getArgumentOutputList(_command)
    }

  end

  self.output:printTable(rows, _player, not commandHasArguments);

end


-- Private Methods

---
-- Returns an output list for all arguments of a command.
--
-- @tparam BaseCommand _command The command
--
-- @treturn string[] The argument output list
--
function CommandHelpTextPrinter:getArgumentOutputList(_command)

  local arguments = {};
  local isFirstArgument = true;

  for i, argument in ipairs(_command:getArguments()) do

    local argumentString = self.argumentPrinter:getFullArgumentString(argument);
    local argumentDescription = self.output:getColor("helpDescription") .. argument:getDescription();

    if (argument:getIsOptional()) then
      argumentDescription = argumentDescription .. " (Optional)";
    end

    -- Determine the prefix of the argumentName
    if (isFirstArgument) then

      -- The first argument is in the same line like the title "Arguments", so it must contain a colon
      argumentString = ": " .. argumentString;
      isFirstArgument = false;

    else
      -- All other lines may not contain colons
      argumentString = "  " .. argumentString;
    end

    table.insert(arguments, {argumentString, argumentDescription});

  end

  return arguments;

end


return CommandHelpTextPrinter;
