---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

local BaseCommand = require("Commands/BaseCommand");
local Output = require("Outputs/Output");

--
-- Command !maptop
--
local MapTopCommand = {};
setmetatable(MapTopCommand, {__index = BaseCommand});


function MapTopCommand:__construct(_parentCommandLister)

  local instance = BaseCommand:__construct(_parentCommandLister, "maptop", 0, "Map records");
  setmetatable(instance, {__index = MapTopCommand});
  
  instance:addAlias("mtop");
  instance:setDescription("Shows the 5 best players of a map");
  
  return instance;

end


--
-- Displays the 5 best players of a map to a player.
--
-- @param int _cn       Client number of the player that executed the command
-- @param array _args   Additional arguments
--
function MapTopCommand:execute(_cn, _args)

  local mapTop = self.parentCommandLister:getParentCommandHandler():getParentGemaMod():getMapTop();
  mapTop:printMapTop(_cn);

end


return MapTopCommand;
