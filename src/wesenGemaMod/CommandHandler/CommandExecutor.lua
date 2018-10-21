---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require("Util/Exception");
local TableUtils = require("Util/TableUtils");

---
-- Handles command execution.
--
-- @type CommandExecutor
--
local CommandExecutor = setmetatable({}, {});


---
-- CommandExecutor constructor.
--
-- @treturn CommandExecutor The CommandExecutor instance
--
function CommandExecutor:__construct()

  local instance = setmetatable({}, {__index = CommandExecutor});

  return instance;

end

getmetatable(CommandExecutor).__call = CommandExecutor.__construct;


-- Public Methods

---
-- Executes a command.
--
-- @tparam BaseCommand _command The command
-- @tparam string[] _arguments The arguments
-- @tparam int _player The player who tries to execute the command
--
-- @treturn string|nil The error message or nil if no error occured
--
-- @raise Error in case of wrong number of arguments
-- @raise Error during the argument validation
-- @raise Error during the command execution
-- @raise Error because of missing permission to use the command
--
function CommandExecutor:executeCommand(_command, _arguments, _player)

  if (_player:getLevel() >= _command:getRequiredLevel()) then

    local numberOfArguments = TableUtils:getTableLength(_arguments);

    -- Check whether the number of arguments is valid
    if (numberOfArguments < _command:getNumberOfRequiredArguments()) then
      error(Exception("Not enough arguments."));
    elseif (numberOfArguments > _command:getNumberOfArguments()) then
      error(Exception("Too many arguments"));
    end

    -- Validate the input arguments
    _command:validateInputArguments(_arguments);

    -- Adjust the input arguments (if needed)
    local arguments = _command:adjustInputArguments(_arguments);

    -- Execute the command
    return _command:execute(_player, arguments);

  else
    error(Exception("No permission to use this command!"));
  end

end


return CommandExecutor;
