---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- 

---
-- Automatically loads all commands.
--
local CommandLoader = {};


CommandLoader.parentCommandHandler = "";


---
-- CommandLoader constructor.
-- 
function CommandLoader:__construct(_parentCommandHandler)

  local instance = {};
  setmetatable(instance, {__index = CommandLoader});
  
  instance.parentCommandHandler = _parentCommandHandler;
  
  return instance;

end


function CommandLoader:loadCommands(_commandLister)
  
  local lfs = require("lfs"); 

  -- iterate over each file in the Commands directory 
  for luaFile in lfs.dir("lua/scripts/src/wesenGemaMod/Commands") do 
 
    if (luaFile ~= "." and luaFile ~= "..") then
    
      -- Don't load the base command since its just a structure for the real commands
      if (luaFile ~= "BaseCommand.lua") then

        local command = require("Commands/" .. luaFile:gsub(".lua", ""));
        
        _commandLister:addCommand(command);   
        print("Loaded command !" .. luaFile:gsub(".lua", ""));
        
      end
 
    end 
 
  end 

end


return CommandLoader;
