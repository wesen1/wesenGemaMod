---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- 

---
-- Class that handles map changes.
--
local MapChangeHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
-- 
-- @param GemaMod parentGemaMod
-- 
MapChangeHandler.parentGemaMod = "";


---
-- MapChangeHandler constructor.
-- 
-- @param GemaMod _parentGemaMod The parent gema mod
--
function MapChangeHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = MapChangeHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;
  
end

---
-- Event handler which is called when the map is changed.
--
-- @param String _mapName Name of the new map
--
function MapChangeHandler:onMapChange(_mapName)

  local mapTop = self.parentGemaMod:getMapTop();

  mapTop:setMapName(_mapName);
  mapTop:loadRecords(_mapName);
  mapTop:printMapStatistics();
  
end


return MapChangeHandler;
