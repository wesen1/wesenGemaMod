---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

local Output = require("Outputs/Output");
local TableOutput = require("Outputs/TableOutput");

---
-- Handles printing of commands in !cmds and !help.
-- 
local CommandPrinter = {};


CommandPrinter.parentCommandHandler = "";


---
-- CommandPrinter constructor.
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
-- @param _command (BaseCommand) The command
-- @param _showOnlyRequiredArguments (bool) Indicates whether only required arguments will be added to the command string
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
-- @param _command (BaseCommand) The command
-- 
-- @return (table) Argument output list
--
function CommandPrinter:getArgumentOutputList(_command)
  
  local arguments = {};
          
  for i, argument in ipairs(_command:getArguments()) do

    local argumentName = "<" .. argument["name"] .. ">";
    local argumentDescription = argument["description"];

    if (argument["isRequired"]) then 
      argumentName = Output:getColor("requiredArgument") .. argumentName;
    else
      argumentName = Output:getColor("optionalArgument") .. argumentName;
      argumentDescription = argumentDescription .. " (Optional)";
    end
    
    local prefix = "  ";
    if (i == 1) then
      prefix = ": ";
    end
    
    table.insert(arguments, {
      prefix .. argumentName,
      Output:getColor("helpDescription") .. ": " .. argumentDescription
    });

  end
  
  return arguments;

end

---
-- Prints the list of available commands to a player.
-- 
-- @param _cn (int) Player cn
--
function CommandPrinter:printCommandList(_cn, _commandLister)

  Output:print(Output:getColor("cmdsTitle") .. "Available commands:");
  
  local rows = {};
  
  for i, level in pairs (_commandLister:getSortedLevels()) do
    
    if (self.parentCommandHandler:getParentGemaMod():getPlayers()[_cn]:getLevel() < level) then
      break;
    end
    
    local groups = _commandLister:getSortedGroups();
    
    for j, groupName in pairs(groups[level]) do
    
      local commandLists = _commandLister:getSortedCommands();
      local commandOutput = ": ";
                        
      for i, commandName in pairs(commandLists[level][groupName]) do      
      
        local command = _commandLister:getCommand("!" .. commandName);
        commandOutput = commandOutput .. CommandPrinter:generateCommandString(command, true) .. "   ";
        
      end
      
      local row = {
        " " .. groupName,
        commandOutput
      };
      
      table.insert(rows, row);
              
    end
    
    TableOutput:printTable(rows, _cn);
    
  end
  
end

---
-- Prints the help text for a command.
-- 
-- @param _command (BaseCommand) The command
-- @param _cn (int) Player cn to which the help text will be printed
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
    
    TableOutput:printTable(rows);
        
end


return CommandPrinter;
