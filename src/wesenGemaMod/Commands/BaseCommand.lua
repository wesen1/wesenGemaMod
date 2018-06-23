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
local BaseCommand = {};

---
-- The main command name (must not contain a leading "!" and must be lowercase)
--
-- @tfield string name
--
BaseCommand.name = "";

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
BaseCommand.description = "";

---
-- Group to which the command belongs (Default: "Other")
-- Will be used to order the output of !cmds
--
-- @tfield string group
--
BaseCommand.group = "Other";

---
-- The parent command lister
--
-- @tfield CommandLister parentCommandLister
--
BaseCommand.parentCommandLister = "";


---
-- BaseCommand constructor.
--
-- @tparam CommandLister _parentCommandLister The parent command lister
-- @tparam string _name The name of the command
-- @tparam int _requiredLevel The minimum required level that is necessary to execute the command
-- @tparam string _group The group of the command
--
-- @treturn BaseCommand The BaseCommand instance
--
function BaseCommand:__construct(_parentCommandLister, _name, _requiredLevel, _group)

  local instance = {};

  instance.parentCommandLister = _parentCommandLister;

  instance.name = _name;
  instance.requiredLevel = _requiredLevel;

  if (_group) then
    instance.group = _group;
  end

  instance.aliases = {};
  instance.arguments = {};

  return instance;

end


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
-- Sets the command name.
--
-- @tparam string _name The command name
--
function BaseCommand:setName(_name)
  self.name = _name;
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
-- Sets the command aliases.
--
-- @tparam string[] _aliases The command aliases
--
function BaseCommand:setAliases(_aliases)
  self.aliases = _aliases;
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
-- Sets the minimum required level that is necessary to execute this command.
--
-- @tparam int _requiredLevel The minimum required level that is necessary to execute this command
--
function BaseCommand:setRequiredLevel(_requiredLevel)
  self.requiredLevel = _requiredLevel;
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
-- Sets the command arguments.
--
-- @tparam table _arguments The command arguments
--
function BaseCommand:setArguments(_arguments)
  self.arguments = _arguments;
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
-- Sets the command description.
--
-- @tparam string _description The command description
--
function BaseCommand:setDescription(_description)
  self.description = _description;
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
-- Sets the command group.
--
-- @tparam string _group The command group
--
function BaseCommand:setGroup(_group)
  self.group = _group;
end

---
-- Returns the parent command lister.
--
-- @treturn CommandLister The parent command lister
--
function BaseCommand:getParentCommandLister()
  return self.parentCommandLister;
end

---
-- Sets the parent command lister.
--
-- @tparam CommandLister _parentCommandLister The parent command lister
--
function BaseCommand:setParentCommandLister(_parentCommandLister)
  self.parentCommandLister = _parentCommandLister;
end


-- Class Methods

---
-- Adds an alias to the alias list.
--
-- @tparam string _alias An alternative name for the command
--
function BaseCommand:addAlias(_alias)
  table.insert(self.aliases, "!" .. _alias);
end

---
-- Adds an argument to the command.
--
-- @tparam string _name The argument name
-- @tparam bool _isRequired True: The argument is required for executing the command
--                          False: The argument is not required for executing the command
-- @tparam string _description The short description of the argument
--
function BaseCommand:addArgument(_name, _isRequired, _description)

  local argument = {};
  argument["name"] = _name;
  argument["isRequired"] = _isRequired;
  argument["description"] = _description;

  table.insert(self.arguments, argument);

end

---
-- Returns the amount of required arguments of this command.
--
-- @treturn int The number of required arguments
--
function BaseCommand:getNumberOfRequiredArguments()

  local count = 0;

  for i, argument in ipairs(self.arguments) do

    if (argument["isRequired"] == true) then
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
-- @tparam string _alias The alias lookup
--
-- @treturn bool True: The alias exists
--               False: The alias does not exist
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
-- @tparam int _cn The client number of the player who called the command
-- @tparam string[] _args The list of arguments which were passed by the player
--
function BaseCommand:execute(_cn, _args)
end


return BaseCommand;
