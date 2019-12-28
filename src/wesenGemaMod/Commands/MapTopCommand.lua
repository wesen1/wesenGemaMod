---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("CommandHandler/BaseCommand");
local StaticString = require("Output/StaticString");

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
-- @treturn MapTopCommand The MapTopCommand instance
--
function MapTopCommand:__construct()

  local instance = BaseCommand(
    StaticString("mapTopCommandName"):getString(),
    0,
    StaticString("mapTopCommandGroupName"):getString(),
    {},
    StaticString("mapTopCommandDescription"):getString(),
    { StaticString("mapTopCommandAlias1"):getString() }
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

  local mapRecordList = mapTopHandler:getMapTop("main"):getMapRecordList();
  local numberOfDisplayRecords = 5;
  local startRank = 1;

  self.output:printTableTemplate(
    "TableTemplate/MapTop/MapTop",
    { ["mapRecordList"] = mapRecordList,
      ["numberOfDisplayRecords"] = numberOfDisplayRecords,
      ["startRank"] = startRank
    }
    , _player
  )

end


return MapTopCommand;
