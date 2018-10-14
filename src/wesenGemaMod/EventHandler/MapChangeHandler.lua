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

    -- Print the map statistics for the map
    for cn, player in pairs(self.parentGemaMode:getPlayerList():getPlayers()) do
      mapTopHandler:getMapTopPrinter():printMapStatistics(mapTop, player);
    end
    
  end

end


-- Private Methods

---
-- Updates the gema mode state if necessary.
-- The gema mod environment must be updated before this method is called.
--
function MapChangeHandler:updateGemaModeState()

  local environmentHandler = self.parentGemaMode:getEnvironmentHandler();
  local mapRot = self.parentGemaMode:getMapRot();
  
  -- Update the environments
  environmentHandler:changeToNextEnvironment(mapRot);
  
  -- Check the current environment
  local isCurrentEnvironmentGemaCompatible = environmentHandler:isCurrentEnvironmentGemaCompatible();

  -- Check whether gema mode must be disabled or enabled
  if (self.parentGemaMode:getIsActive() and not isCurrentEnvironmentGemaCompatible) then
    self.parentGemaMode:setIsActive(false);
    self.output:printInfo("The gema mode was automatically disabled. Vote a gema map in ctf to reenable it.");
    -- TODO: Update server name

  elseif (not self.parentGemaMode:getIsActive() and isCurrentEnvironmentGemaCompatible) then
    self.parentGemaMode:setIsActive(true);
    self.output:printInfo("The gema mode was automatically enabled.");
    -- TODO: Update server name
  end

end


return MapChangeHandler;
