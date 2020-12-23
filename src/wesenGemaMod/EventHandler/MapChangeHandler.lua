---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");

---
-- Class that handles map changes.
-- MapChangeHandler inherits from BaseEventHandler
--
-- @type MapChangeHandler
--
local MapChangeHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- MapChangeHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn MapChangeHandler The MapChangeHandler instance
--
function MapChangeHandler:__construct(_parentGemaMode)

  local instance = BaseEventHandler(_parentGemaMode, "onMapChange");
  setmetatable(instance, {__index = MapChangeHandler});

  return instance;

end

getmetatable(MapChangeHandler).__call = MapChangeHandler.__construct;


-- Public Methods

---
-- Event handler which is called when the map is changed.
--
-- @tparam string _mapName The name of the new map
-- @tparam int _gameMode The game mode
--
function MapChangeHandler:handleEvent(_mapName, _gameMode)

  -- If gema mode is still active
  if (self.parentGemaMode:getIsActive()) then

    local mapTopHandler = self.parentGemaMode:getMapTopHandler();
    local mapTop = mapTopHandler:getMapTop("main");

    -- Load the map records for the map
    mapTop:loadRecords(_mapName);

    -- Print the map statistics for the map to all players
    self.output:printTableTemplate(
      "TableTemplate/MapTop/MapStatistics", { ["mapRecordList"] = mapTop:getMapRecordList() }
    )

  end

end


return MapChangeHandler;
