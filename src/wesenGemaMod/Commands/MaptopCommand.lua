---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("CommandHandler/BaseCommand");

---
-- Command !maptop.
-- Displays the best records of a map to a player
-- MapTopCommand inherits from BaseCommand
--
-- @type MapTopCommand
--
local MapTopCommand = setmetatable({}, {__index = BaseCommand});


---
-- MapTopCommand constructor.
--
-- @tparam CommandList _parentCommandList The parent command list
--
-- @treturn MapTopCommand The MapTopCommand instance
--
function MapTopCommand:__construct(_parentCommandList)

  local instance = BaseCommand(
    _parentCommandList,
    "!maptop",
    0,
    "Map records",
    {},
    "Shows the 5 best players of a map",
    { "!mtop" }
  );
  setmetatable(instance, {__index = MapTopCommand});

  return instance;

end

getmetatable(MapTopCommand).__call = MapTopCommand.__construct;


-- Public Methods

---
-- Displays the 5 best players of a map to a player.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
function MapTopCommand:execute(_player, _arguments)
  local mapTopHandler = self.parentCommandList:getParentGemaMode():getMapTopHandler();
  local mapTop = mapTopHandler:getMapTop("main");
  mapTopHandler:getMapTopPrinter():printMapTop(mapTop, _player);
end


return MapTopCommand;
