---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

local Output = require("Outputs/Output");
local StringUtils = require("Utils/StringUtils");
local TableUtils = require("Utils/TableUtils");

---
-- Handles command parsing and execution.
--
local CommandParser = {};


CommandParser.parentCommandHandler = "";

---
-- CommandParser constructor.
-- 
function CommandParser:__construct(_parentCommandHandler)

  local instance = {};
  setmetatable(instance, {__index = CommandParser});
  
  instance.parentCommandHandler = _parentCommandHandler;
  
  return instance;

end


--
-- Checks whether a string is starting with "!" followed by other characters than !.
--
-- @param string _commandName   The string which will be checked
--
-- @return bool       True: The string is a command
--                    False: The string is not a command
--
function CommandParser:isCommand(_text)
  
  -- if first character is "!" and second is not "!"
  if string.sub(_text,1,1) == "!" and string.sub(_text,2,2) ~= "!" then
    return true;
  else
    return false;
  end  
  
end

--
-- Splits the input into command name and arguments and tries to execute the command.
--
-- @param String _text  Input text in the format "!commandName args"
-- @param int _cn        Client number of the player who tries to execute the command
--
function CommandParser:parseCommand(_text, _cn)

  local parts = StringUtils:split(_text, " ");
  local commandName = string.lower(parts[1]);
  
  local args = {};
  if (#parts > 1) then
    args = TableUtils:slice(parts, 2);
  end
  
  local command = self.parentCommandHandler:getCommand(commandName);
      
  if (command) then
  
    local player = self.parentCommandHandler:getParentGemaMod():getPlayers()[_cn];
         
    if (player:getLevel() >= command:getRequiredLevel()) then
        
      if (#args < command:getNumberOfRequiredArguments()) then
        Output:print(Output:getColor("error") .. "Error: Not enough arguments.");
      
      elseif (#args > command:getNumberOfArguments()) then
        Output:print(Output:getColor("error") .. "Error: Too many arguments");
        
      else
        command:execute(_cn, args);
      
      end
      
    else
      Output:print(Output:getColor("error") .. "Error: You do not have the permission to use this command!", _cn);
    end 
      
  else   
    
    Output:print(Output:getColor("error") .. "Unknown command '" .. commandName .. "', check your spelling and try again", _cn);
  
  end
  
end


return CommandParser;
