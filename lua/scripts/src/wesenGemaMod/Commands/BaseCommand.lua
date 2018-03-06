---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

--- 
-- Stores the configuration for a single command.
--
local BaseCommand = {};

---
-- @field name (String) The main command name (must not contain a leading "!" and must be lowercase)
-- 
BaseCommand.name = "";

---
-- @field aliases (table) The alternative command names (must not contain a leading "!" and must be lowercase)
-- 
BaseCommand.aliases = {};

---
-- @field requiredLevel (int) Player level that is necessary to call the command
-- 
-- Possible values are:
--   - 0: everyone is allowed to use this command
--   - 1: only admins are allowed to use this command
--   
BaseCommand.requiredLevel = 0;

---
-- @field arguments (table) List of arguments that can/must be passed when calling the command
-- 
-- Add arguments in the order in which you want them to be displayed in !cmds
-- 
BaseCommand.arguments = {};

---
-- @field description (String) Short description of what the command does
-- 
-- Will be displayed when someone uses the !help command
-- 
BaseCommand.description = "";

---
-- @field group (String) Group to which the command belongs
--
-- Will be used to order the output of !cmds
-- The default command group is "Other"
-- 
BaseCommand.group = "Other";

BaseCommand.parentCommandLister = "";


---
-- BaseCommand constructor.
--
-- @param CommandLister _parentCommandLister The parent command lister
-- @param String _name              Name of the command
-- @param int _requiredlevel        Level that is required in order to execute the command
-- @param _group (String) Group of the command
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

-- Getters and Setters
function BaseCommand:setName(_name)
  self.name = _name;
end

function BaseCommand:getName()
  return self.name;
end

function BaseCommand:setAliases(_aliases)
  self.aliases = _aliases;
end

function BaseCommand:getAliases()
  return self.aliases;
end

function BaseCommand:setRequiredLevel(_requiredLevel)
  self.requiredLevel = _requiredLevel;
end

function BaseCommand:getRequiredLevel()
  return self.requiredLevel;
end

function BaseCommand:setArguments(_arguments)
  self.arguments = _arguments;
end

function BaseCommand:getArguments()
  return self.arguments;
end

function BaseCommand:setDescription(_description)
  self.description = _description;
end

function BaseCommand:getDescription()
  return self.description;
end

function BaseCommand:setGroup(_group)
  self.group = _group;
end

function BaseCommand:getGroup()
  return self.group;
end


--
-- Adds an alias to the alias list.
--
-- @param String _alias   An alternative name for the command
--
function BaseCommand:addAlias(_alias)
  table.insert(self.aliases, "!" .. _alias);
end

--
-- Adds an argument to the command.
--
-- @param String _name         The argument name
-- @param bool _isRequired     true: argument is required for executing the command
--                             false: argument is not required for executing the command
-- @param String _description  Short description of the argument
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
-- @return (int) Number of required arguments
-- 
function BaseCommand:getNumberOfRequiredArguments()

  local count = 0;

  for i, argument in ipairs(self.arguments) do
  
    if (argument.isRequired == true) then
      count = count + 1;
    end
    
  end
  
  return count;

end

---
-- Returns the total amount of arguments of this command.
-- 
-- @return (int) Number of arguments
-- 
function BaseCommand:getNumberOfArguments()

  return #self.arguments;

end

---
-- Returns whether this command has an alias named _alias.
-- 
-- @param _alias (String) Alias lookup
-- 
-- @return bool true: alias exists
--              false: alias doesn't exist
--
function BaseCommand:hasAlias(_alias)

  for i, alias in pairs(self.aliases) do
  
    if (alias == _alias:lower()) then
      return true;
    end
  
  end
  
  return false;

end

---
-- Will be called when someone executes the command.
-- Must be overwritten in each command
--
function BaseCommand:execute(_cn, _args)
end


return BaseCommand;
