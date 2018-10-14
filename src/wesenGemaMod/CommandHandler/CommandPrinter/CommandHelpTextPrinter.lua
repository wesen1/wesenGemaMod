---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local CommandPrinter = require("CommandHandler/CommandPrinter/CommandPrinter");

---
-- Displays the help texts of commands.
--
-- @type CommandHelpTextPrinter
--
local CommandHelpTextPrinter = setmetatable({}, {});


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

  -- TODO: Add required level to description
  local rows = {
    [1] = {
      self.output:getColor("helpTitle") .. "Usage ",
        ": " .. self.commandPrinter:generateCommandString(_command, true)
    },
    [2] = {
        self.output:getColor("helpTitle") .. "Description ",
        ": " .. self.output:getColor("helpDescription") .. _command:getDescription()
    }
  }

  local commandHasArguments = _command:getNumberOfArguments() > 0;
  if (commandHasArguments) then

    rows[3] = {
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

  for i, argument in ipairs(_command:getArguments()) do

    local argumentName = "<" .. argument["name"] .. ">";
    local argumentDescription = self.output:getColor("helpDescription") .. ": " .. argument["description"];

    -- Set the output color for the argument name
    if (argument["isRequired"]) then
      argumentName = self.output:getColor("requiredArgument") .. argumentName;
    else
      argumentName = self.output:getColor("optionalArgument") .. argumentName;
      argumentDescription = argumentDescription .. " (Optional)";
    end

    -- Determine the prefix of the argumentName
    if (i == 1) then
      -- The first argument is in the same line like the title "Arguments", so it must contain a colon
      argumentName = ": " .. argumentName;
    else
      -- All other lines may not contain colons
      argumentName = "  " .. argumentName;
    end

    table.insert(arguments, {argumentName, argumentDescription});

  end

  return arguments;

end


return CommandHelpTextPrinter;
