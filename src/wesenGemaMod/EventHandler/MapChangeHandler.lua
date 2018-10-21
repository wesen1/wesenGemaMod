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

  local instance = BaseEventHandler(_parentGemaMode);
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
function MapChangeHandler:onMapChange(_mapName, _gameMode)

  self:updateGemaModeState();

  -- If gema mode is still active
  if (self.parentGemaMode:getIsActive()) then

    local mapTopHandler = self.parentGemaMode:getMapTopHandler();
    local mapTop = mapTopHandler:getMapTop("main");

    -- Load the map records for the map
    mapTop:loadRecords(self.parentGemaMode:getDataBase(), _mapName);

    -- Print the map statistics for the map to all players
    mapTopHandler:getMapTopPrinter():printMapStatistics(mapTop);

      --@todo: Use setmotd() for greeting + map statistics stuff, or just edit the file

  end

end


-- Private Methods

---
-- Updates the gema mode state if necessary.
--
function MapChangeHandler:updateGemaModeState()

  local gemaModeStateUpdater = self.parentGemaMode:getGemaModeStateUpdater();
  local newGemaModeState = gemaModeStateUpdater:switchToNextEnvironment();

  if (newGemaModeState == true) then
    self.output:printInfo("The gema mode was automatically enabled.");
  elseif (newGemaModeState == false) then
    self.output:printInfo("The gema mode was automatically disabled. Vote a gema map in ctf to reenable it.");
  end

end

return MapChangeHandler;
