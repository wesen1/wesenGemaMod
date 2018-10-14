---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Stores the configuration for a single command.
--
-- @type BaseCommand
--
local BaseCommand = setmetatable({}, {});

---
-- The main command name (with leading "!")
-- Command names must must be lowercase
--
-- @tfield string name
--
BaseCommand.name = nil;

---
-- The alternative command names (must not contain a leading "!" and must be lowercase)
--
-- @tfield string[] aliases
--
BaseCommand.aliases = {};

---
-- The minimum player level that is necessary to call the command
--
-- Possible values are:
--   0: everyone
--   1: admin
--
-- @tfield int requiredLevel
--
BaseCommand.requiredLevel = 0;

---
-- List of arguments that can/must be passed when calling the command
-- Arguments will be displayed in the order in which they were added with BaseCommand:addArgument()
--
-- @tfield table arguments
--
BaseCommand.arguments = {};

---
-- Short description of what the command does
-- Will be displayed when someone uses the !help command on this command
--
-- @tfield string description
--
BaseCommand.description = "No description";

---
-- Group to which the command belongs (Default: "General")
-- Will be used to order the output of !cmds
--
-- @tfield string group
--
BaseCommand.group = "General";

---
-- The parent command list
--
-- @tfield CommandList parentCommandList
--
BaseCommand.parentCommandList = nil;

---
-- The output
--
-- @tfield Output output
--
BaseCommand.output = nil;


---
-- BaseCommand constructor.
--
-- @tparam CommandList _parentCommandList The parent command list
-- @tparam string _name The name of the command
-- @tparam int _requiredLevel The minimum required level that is necessary to execute the command
-- @tparam string _group The group of the command
-- @tparam CommandArgument[] _arguments The commands arguments
-- @tparam string _description The description of the command
-- @tparam string[] _aliases The list of aliases for the command
--
-- @treturn BaseCommand The BaseCommand instance
--
function BaseCommand:__construct(_parentCommandList, _name, _requiredLevel, _group, _arguments, _description, _aliases)

  local instance = setmetatable({}, {__index = BaseCommand});

  instance.parentCommandList = _parentCommandList;
  instance.output = _parentCommandList:getParentGemaMode():getOutput();
  instance.name = _name;
  
  if (_requiredLevel) then
    instance.requiredLevel = _requiredLevel;
  end

  if (_group) then
    instance.group = _group;
  end
  
  if (_description) then
    instance.description = _description;
  end
  
  if (_arguments) then
    instance.arguments = _arguments;
  else
    instance.aliases = {};
  end
  
  if (_aliases) then
    instance.aliases = _aliases;
  else
    instance.aliases = {};
  end

  return instance;

end

getmetatable(BaseCommand).__call = BaseCommand.__construct;


-- Getters and setters

---
-- Returns the command name.
--
-- @treturn string The command name
--
function BaseCommand:getName()
  return self.name;
end

---
-- Returns the command aliases.
--
-- @treturn string[] The command aliases
--
function BaseCommand:getAliases()
  return self.aliases;
end

---
-- Returns the minimum required level that is necessary to execute this command.
--
-- @treturn int The minimum required level that is necessary to execute this command
--
function BaseCommand:getRequiredLevel()
  return self.requiredLevel;
end

---
-- Returns the command arguments.
--
-- @treturn table The command arguments
--
function BaseCommand:getArguments()
  return self.arguments;
end

---
-- Returns the command description.
--
-- @treturn string The command description
--
function BaseCommand:getDescription()
  return self.description;
end

---
-- Returns the command group.
--
-- @treturn string The command group
--
function BaseCommand:getGroup()
  return self.group;
end

---
-- Returns the parent command list.
--
-- @treturn CommandList The parent command list
--
function BaseCommand:getParentCommandList()
  return self.parentCommandList;
end


-- Public Methods

---
-- Returns the amount of required arguments of this command.
--
-- @treturn int The number of required arguments
--
function BaseCommand:getNumberOfRequiredArguments()

  local count = 0;

  for i, argument in ipairs(self.arguments) do
    if (argument:getIsOptional() == false) then
      count = count + 1;
    end
  end

  return count;

end

---
-- Returns the total number of arguments of this command.
--
-- @treturn int The total number of arguments
--
function BaseCommand:getNumberOfArguments()
  return #self.arguments;
end

---
-- Returns whether this command has an alias named _alias.
--
-- @tparam string _alias The alias lookup with leading "!"
--
-- @treturn bool True if the alias exists, false otherwise
--
function BaseCommand:hasAlias(_alias)

  for i, alias in pairs(self.aliases) do

    if (alias:lower() == _alias:lower()) then
      return true;
    end

  end

  return false;

end

---
-- Will be called when someone executes the command.
-- Must be overwritten in each command
--
-- @tparam Player _player The player who called the command
-- @tparam mixed[] _arguments The list of arguments which were passed by the player
--
function BaseCommand:execute(_player, _arguments)
end

---
-- Will be called on command execution when this command has arguments.
-- This method should check whether all input arguments are valid before the execution can continue.
--
-- @tparam mixed[] _arguments The list of arguments
--
-- @raise Error in case of an invalid input argument
--
function BaseCommand:validateInputArguments(_arguments)
end

---
-- Will be called after the input arguments were validated.
-- This method should adjust the input arguments as necessary for the command
--
-- @tparam mixed[] The list of arguments
--
-- @treturn mixed[] The updated list of arguments
--
function BaseCommand:adjustInputArguments(_arguments)
  return _arguments;
end


return BaseCommand;