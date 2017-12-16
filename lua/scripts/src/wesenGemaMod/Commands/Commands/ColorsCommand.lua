---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

require("BaseCommand");
require("Output");


-- Command !colors
--
-- Displays all available colors to a player.
--
Colors = BaseCommand:__construct("colors", 0, "Colors");
Colors:setDescription("Shows a list of all available colors");

--
-- Displays all available colors to a player.
--
-- @param int _cn       Client number of the player that executed the command
-- @param array _args   Additional arguments
--
function Colors:execute(_cn, _args)

  local symbols = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
  local output = "";

  for i = 1, #symbols do

    local symbol = symbols:sub(i,i);
    output = output .. "\f" .. symbol .. " " .. symbol;

  end
  
  Output:print(output, _cn);
  
end


return Colors;

