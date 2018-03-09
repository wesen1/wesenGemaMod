---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Output = require("Outputs/Output");
local StringUtils = require("Utils/StringUtils");
local TableUtils = require("Utils/TableUtils");

---
-- @type CommandParser Handles command parsing and execution.
--
local CommandParser = {};


---
-- The parent command handler
--
-- @tfield CommandHandler parentCommandHandler
--
CommandParser.parentCommandHandler = "";


---
-- CommandParser constructor.
--
-- @tparam CommandHandler _parentCommandHandler The parent command handler
--
-- @treturn CommandParser The CommandParser instance
--
function CommandParser:__construct(_parentCommandHandler)

  local instance = {};
  setmetatable(instance, {__index = CommandParser});

  instance.parentCommandHandler = _parentCommandHandler;

  return instance;

end


---
-- Checks whether a string starts with "!" followed by other characters than "!".
--
-- @tparam string _text The string
--
-- @treturn bool True: The string is a command
--               False: The string is not a command
--
function CommandParser:isCommand(_text)

  -- if first character is "!" and second is not "!"
  if string.sub(_text,1,1) == "!" and string.sub(_text,2,2) ~= "!" then
    return true;
  else
    return false;
  end

end

---
-- Splits an input text into command name and arguments and executes the command if it exists.
--
-- @tparam string _inputText The input text in the format "!commandName args"
-- @tparam int _cn The client number of the player who tries to execute the command
--
function CommandParser:parseCommand(_inputText, _cn)

  local inputTextParts = StringUtils:split(_inputText, " ");
  local commandName = string.lower(inputTextParts[1]);
  local command = self.parentCommandHandler:getCommand(commandName);

  if (command) then

    local arguments = {};
    if (#inputTextParts > 1) then
      arguments = TableUtils:slice(inputTextParts, 2);
    end

    self:executeCommand(command, arguments, _cn);

  else
    Output:print(Output:getColor("error") .. "Unknown command '" .. commandName .. "', check your spelling and try again", _cn);
  end

end

---
-- Executes a command.
--
-- @tparam BaseCommand _command The command
-- @tparam string[] _arguments The arguments
-- @tparam int The client number of the player who tries to execute the command
--
function CommandParser:executeCommand(_command, _arguments, _cn)

  local player = self.parentCommandHandler:getParentGemaMod():getPlayers()[_cn];

  if (player:getLevel() >= _command:getRequiredLevel()) then

    if (#_arguments < _command:getNumberOfRequiredArguments()) then
      Output:print(Output:getColor("error") .. "Error: Not enough arguments.");

    elseif (#_arguments > _command:getNumberOfArguments()) then
      Output:print(Output:getColor("error") .. "Error: Too many arguments");

    else
      _command:execute(_cn, _arguments);

    end

  else
    Output:print(Output:getColor("error") .. "Error: You do not have the permission to use this command!", _cn);
  end

end


return CommandParser;
