---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

---
-- Event handler which is called when the map is changed.
--
-- @param string _mapName   Name of the new map
--
function onMapChange (_mapName)

  mapTop:setMapName(_mapName);
  mapTop:loadRecords(_mapName);
  mapTop:printMapStatistics();
  
end