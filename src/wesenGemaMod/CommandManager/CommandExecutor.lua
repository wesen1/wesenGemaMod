---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"
local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"

---
-- Handles command execution.
--
-- @type CommandExecutor
--
local CommandExecutor = Object:extend()


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

    -- The CommandExecutor relies on the CommandParser to check that all arguments are valid

    -- Validate the input arguments
    _command:validateInputArguments(_arguments)

    -- Adjust the input arguments (if needed)
    local arguments = _command:adjustInputArguments(_arguments)

    -- Execute the command
    return _command:execute(_player, arguments)

  else
    error(TemplateException(
      "CommandManager/Exceptions/NoPermissionToUseCommand",
      { command = _command, player = _player }
    ))
  end

end


return CommandExecutor
