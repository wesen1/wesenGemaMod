---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Output = require("Outputs/Output");
local TableOutput = require("Outputs/TableOutput");

---
-- @type CommandPrinter Handles printing of commands in !cmds and !help.
--
local CommandPrinter = {};


---
-- The parent command handler
--
-- @tfield CommandHandler parentCommandHandler
--
CommandPrinter.parentCommandHandler = "";


---
-- CommandPrinter constructor.
--
-- @tparam CommandHandler _parentCommandHandler The parent command handler
--
-- @treturn CommandPrinter The CommandPrinter instance
--
function CommandPrinter:__construct(_parentCommandHandler)

  local instance = {};
  setmetatable(instance, {__index = CommandPrinter});

  instance.parentCommandHandler = _parentCommandHandler;

  return instance;

end


---
-- Generates and returns a command string.
--
-- @tparam BaseCommand _command The command
-- @tparam bool _showOnlyRequiredArguments True: Only required arguments will be added to the command string
--                                         False: All arguments will be added to the command string
--
-- @treturn string The command string
--
function CommandPrinter:generateCommandString(_command, _showOnlyRequiredArguments)

  local commandString = Output:getColor("command" .. _command:getRequiredLevel())
                     .. "!" .. _command:getName();

  for i, argument in ipairs(_command:getArguments()) do

    if (not argument["isRequired"] and not _showOnlyRequiredArguments) then
      commandString = commandString
                   .. Output:getColor("optionalArgument")
                   .. " <" .. argument["name"] .. ">";

    elseif (argument["isRequired"]) then
      commandString = commandString
                   .. Output:getColor("requiredArgument")
                   .. " <" .. argument["name"] .. ">";
    end

  end

  return commandString;

end

---
-- Returns an output list for all arguments of a command.
--
-- @tparam BaseCommand _command The command
--
-- @treturn string[] The argument output list
--
function CommandPrinter:getArgumentOutputList(_command)

  local arguments = {};

  for i, argument in ipairs(_command:getArguments()) do

    local argumentName = "<" .. argument["name"] .. ">";
    local argumentDescription = Output:getColor("helpDescription") .. ": " .. argument["description"];

    -- Set the output color for the argument name
    if (argument["isRequired"]) then
      argumentName = Output:getColor("requiredArgument") .. argumentName;
    else
      argumentName = Output:getColor("optionalArgument") .. argumentName;
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

---
-- Prints the list of available commands to a player.
--
-- @tparam int _cn The client number of the player
--
function CommandPrinter:printCommandList(_cn, _commandLister)

  local player = self.parentCommandHandler:getParentGemaMod():getPlayers()[_cn];

  Output:print(Output:getColor("cmdsTitle") .. "Available commands:", _cn);

  local rows = {};

  local groupedCommands = _commandLister:getGroupedCommands();

  for index, level in ipairs(_commandLister:getSortedCommandLevels()) do

    if (player:getLevel() < level) then
      break;
    end

    local commandGroups = groupedCommands[level];

    for level, groupName in ipairs(_commandLister:getSortedCommandGroupNames()[level]) do

      local groupCommandString = "";

      for index, commandName in ipairs(commandGroups[groupName]) do
        local command = _commandLister:getCommand(commandName);
        groupCommandString = groupCommandString .. self:generateCommandString(command, true) .. "   ";
      end

      local row = {
        " " .. groupName,
        ": " .. groupCommandString
      }

      table.insert(rows, row);

    end

  end

  TableOutput:printTable(rows, _cn);

end

---
-- Prints the help text for a command.
--
-- @tparam BaseCommand _command The command
-- @tparam int _cn The client number of the player to which the help text will be printed
--
function CommandPrinter:printHelpText(_command, _cn)

    local rows = {
      [1] = {
        Output:getColor("helpTitle") .. "Usage ",
        ": " .. self:generateCommandString(_command, false)
      },
      [2] = {
        Output:getColor("helpTitle") .. "Description ",
        ": " .. Output:getColor("helpDescription") .. _command:getDescription()
      }
    }

    if (_command:getNumberOfArguments() > 0) then

      rows[3] = {
        Output:getColor("helpTitle") .. "Arguments",
        self:getArgumentOutputList(_command)
      }

    end

    TableOutput:printTable(rows, _cn);

end


return CommandPrinter;
