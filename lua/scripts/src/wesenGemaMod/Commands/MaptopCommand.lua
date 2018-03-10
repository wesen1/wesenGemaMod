---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("Commands/BaseCommand");
local Output = require("Outputs/Output");

---
-- @type MapTopCommand Command !maptop - Displays the best records of a map to a player.
--
local MapTopCommand = {};

-- MapTopCommand inherits from BaseCommand
setmetatable(MapTopCommand, {__index = BaseCommand});


---
-- MapTopCommand constructor.
--
-- @tparam CommandLister _parentCommandLister The parent command lister
--
-- @treturn MapTopCommand The MapTopCommand instance
--
function MapTopCommand:__construct(_parentCommandLister)

  local instance = BaseCommand:__construct(_parentCommandLister, "maptop", 0, "Map records");
  setmetatable(instance, {__index = MapTopCommand});

  instance:addAlias("mtop");
  instance:setDescription("Shows the 5 best players of a map");

  return instance;

end


---
-- Displays the 5 best players of a map to a player.
--
-- @tparam int _cn The client number of the player who executed the command
-- @tparam string[] _args The list of arguments which were passed by the player
--
function MapTopCommand:execute(_cn, _args)
  local mapTop = self.parentCommandLister:getParentCommandHandler():getParentGemaMod():getMapTop();
  mapTop:printMapTop(_cn);
end


return MapTopCommand;
