---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

local BaseCommand = require("Commands/BaseCommand");
local Output = require("Outputs/Output");

---
-- Command !colors
--
-- Displays all available colors to a player.
--
local ColorsCommand = {};
setmetatable(ColorsCommand, {__index = BaseCommand});


function ColorsCommand:__construct(_parentCommandLister)

  local instance = BaseCommand:__construct(_parentCommandLister, "colors", 0, "Colors");
  setmetatable(instance, {__index = ColorsCommand});
  
  
  instance:setDescription("Shows a list of all available colors");
  
  return instance;

end

--
-- Displays all available colors to a player.
--
-- @param int _cn       Client number of the player that executed the command
-- @param array _args   Additional arguments
--
function ColorsCommand:execute(_cn, _args)

  local symbols = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
  local output = "";

  for i = 1, #symbols do

    local symbol = symbols:sub(i,i);
    output = output .. "\f" .. symbol .. " " .. symbol;

  end
  
  Output:print(output, _cn);
  
end


return ColorsCommand;
