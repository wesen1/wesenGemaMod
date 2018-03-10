---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- @type MapChangeHandler Class that handles map changes.
--
local MapChangeHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
--
-- @tfield GemaMod parentGemaMod
--
MapChangeHandler.parentGemaMod = "";


---
-- MapChangeHandler constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn MapChangeHandler The MapChangeHandler instance
--
function MapChangeHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = MapChangeHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;

end


-- Getters and setters

---
-- Returns the parent gema mod.
--
-- @treturn GemaMod The parent gema mod
--
function MapChangeHandler:getParentGemaMod()
  return self.parentGemaMod;
end

---
-- Sets the parent gema mod.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
function MapChangeHandler:setParentGemaMod(_parentGemaMod)
  self.parentGemaMod = _parentGemaMod;
end


-- Class Methods

---
-- Event handler which is called when the map is changed.
--
-- @tparam string _mapName The name of the new map
--
function MapChangeHandler:onMapChange(_mapName)

  local mapTop = self.parentGemaMod:getMapTop();

  mapTop:setMapName(_mapName);
  mapTop:loadRecords(_mapName);
  mapTop:printMapStatistics();

end


return MapChangeHandler;
