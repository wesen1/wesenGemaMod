---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

--@todo: CommandListPrinter should contain the grouped command names, levels, etc.

local CommandPrinter = require("CommandHandler/CommandPrinter/CommandPrinter");

---
-- Displays command lists.
--
-- @type CommandListPrinter
--
local CommandListPrinter = setmetatable({}, {});


---
-- The command printer
--
-- @tfield CommandPrinter commandPrinter
--
CommandListPrinter.commandPrinter = nil;

---
-- The output
--
-- @tfield Output output
--
CommandListPrinter.output = nil;


---
-- CommandListPrinter constructor.
--
-- @tparam Output output The output that can be used by the CommandListPrinter
--
-- @treturn CommandListPrinter The CommandListPrinter instance
--
function CommandListPrinter:__construct(_output)

  local instance = setmetatable({}, {__index = CommandListPrinter});

  instance.output = _output;
  instance.commandPrinter = CommandPrinter(_output);

  return instance;

end

getmetatable(CommandListPrinter).__call = CommandListPrinter.__construct;


-- Public Methods

---
-- Prints the list of available commands to a player.
--
-- @tparam CommandList _commandList The command list
-- @tparam int _maximumLevel The highest command level for that commands are ṕrinted
-- @tparam String _indent The indention string to add in front of each output line
-- @tparam int _player The player
--
function CommandListPrinter:printGroupedCommands(_commandList, _maximumLevel, _indent, _player)

  local rows = {};
  local groupedCommands = _commandList:getGroupedCommands();

  for _, level in ipairs(_commandList:getSortedCommandLevels()) do

    if (_maximumLevel < level) then
      break;
    end

    local commandGroups = groupedCommands[level];

    for _, groupName in ipairs(_commandList:getSortedCommandGroupNames()[level]) do

      local groupCommandString = "";

      for _, commandName in ipairs(commandGroups[groupName]) do
        local command = _commandList:getCommand(commandName);
        groupCommandString = groupCommandString .. self.commandPrinter:generateCommandString(command, false) .. "   ";
      end

      local row = {
        _indent .. groupName,
        ": " .. groupCommandString
      }

      table.insert(rows, row);

    end

  end

  self.output:printTable(rows, _player, true);

end


return CommandListPrinter;
