---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Generates strings to display single commands.
--
-- @type CommandPrinter
--
local CommandPrinter = setmetatable({}, {});


---
-- The output
--
-- @tfield Output output
--
CommandPrinter.output = nil;


---
-- CommandPrinter constructor.
--
-- @tparam Output _output The output that can be used by this CommandPrinter
--
-- @treturn CommandPrinter The CommandPrinter instance
--
function CommandPrinter:__construct(_output)

  local instance = setmetatable({}, {__index = CommandPrinter});

  instance.output = _output;

  return instance;

end

getmetatable(CommandPrinter).__call = CommandPrinter.__construct;


-- Public Methods

---
-- Generates and returns a command string.
--
-- @tparam BaseCommand _command The command
-- @tparam bool _showOptionalArguments If true, optional arguments will be added to the command string
--
-- @treturn string The command string
--
function CommandPrinter:generateCommandString(_command, _showOptionalArguments)

  local commandString = self.output:getColor("command" .. _command:getRequiredLevel())
                     .. _command:getName();

  for i, argument in ipairs(_command:getArguments()) do

    if (not argument:getIsOptional()) then
      commandString = commandString
                   .. self.output:getColor("requiredArgument")
                   .. " <" .. argument:getShortName() .. ">";

    elseif (_showOptionalArguments) then
      commandString = commandString
                   .. self.output:getColor("optionalArgument")
                   .. " <" .. argument:getShortName() .. ">";
    end

  end

  return commandString;

end


return CommandPrinter;
