---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

---
-- Stores a list of all commands.
--
CommandLister = {};

CommandLister.commands = {};
CommandLister.sortedLevels = {};
CommandLister.sortedGroups = {};
CommandLister.sortedCommands = {};

---
-- CommandLister constructor.
-- 
function CommandLister:__construct()

  local instance = {};
  setmetatable(instance, {__index = CommandLister});

  instance.commands = {};
  instance.sortedLevels = {};
  instance.sortedGroups = {};
  instance.sortedCommands = {};
  
  return instance;

end

function CommandLister:getCommands()
  return self.commands;
end

function CommandLister:setCommands(_commands)
  self.commands = _commands;
end

function CommandLister:getSortedLevels()
  return self.sortedLevels;
end

function CommandLister:setSortedLevels(_sortedLevels)
  self.sortedLevels = _sortedLevels;
end

function CommandLister:getSortedGroups()
  return self.sortedGroups;
end

function CommandLister:setSortedGroups(_sortedGroups)
  self.sortedGroups = _sortedGroups;
end

function CommandLister:getSortedCommands()
  return self.sortedCommands;
end

function CommandLister:setSortedCommands(_sortedCommands)
  self.sortedCommands = _sortedCommands;
end

---
-- Adds a command to the command list
-- 
-- @param _command (BaseCommand) The command
--
function CommandLister:addCommand(_command)

  self.commands["!" .. _command:getName()] = _command;
  
  local level = _command:getRequiredLevel();
  local group = _command:getGroup();
  
  if (self.sortedCommands[level] == nil) then
    self.sortedCommands[level] = {};
    table.insert(self.sortedLevels, level);
    table.sort(self.sortedLevels);
  end
  
  if (self.sortedCommands[level][group] == nil) then
    self.sortedCommands[level][group] = {};
    
    if (self.sortedGroups[level] == nil) then
      self.sortedGroups[level] = {};
    end
    table.insert(self.sortedGroups[level], group);
    
    table.sort(self.sortedGroups[level]);
  end
  
  table.insert(self.sortedCommands[level][group], _command:getName());
  table.sort(self.sortedCommands[level][group]);

end

---
-- Returns a command with the name or alias _commandName
-- 
-- @param _commandName (String) The command name
-- 
-- @return (BaseCommand|bool) The command or false
-- 
function CommandLister:getCommand(_commandName)

  if (self.commands[_commandName] ~= nil) then
    return self.commands[_commandName];
  end

  -- Check aliases
  for commandName, command in pairs(self.commands) do
                  
    if (command:hasAlias(_commandName)) then
      return command;
    end
      
  end
  
  return false;

end

