---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

require("BaseCommand");
require("Output");

--
-- Command !maptop
--
Maptop = BaseCommand:__construct("maptop", 0, "Map records");
Maptop:addAlias("mtop");
Maptop:setDescription("Shows the 5 best players of a map");

--
-- Displays the 5 best players of a map to a player.
--
-- @param int _cn       Client number of the player that executed the command
-- @param array _args   Additional arguments
--
function Maptop:execute(_cn, _args)

  mapTop:printMapTop(_cn);

end


return Maptop;

