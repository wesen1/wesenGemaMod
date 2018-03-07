---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- 

local TableUtils = require("Utils/TableUtils");

--
-- Handles removal of maps.
--
local MapRemover = {};

--
-- Removes a map from the database and the maps folder.
--
-- @param String _mapName   Name of the map
--
-- @return bool  Success
--
function MapRemover:removeMap(_dataBase, _mapName, _mapId, _mapTop)

  if (self:mapHasRecords(_dataBase, _mapName, _mapTop)) then
    return false;
  else

    -- remove map from database
    local sql = "DELETE FROM maps "
                 .. "WHERE id=" .. _mapId .. ";";
    _dataBase:query(sql, false);
  
    -- remove map files
    removemap(_mapName, _mapTop);
    
    return true;
    
  end

end

---
-- Returns whether a map has records.
--
-- @tparam DataBase _dataBase The database
-- @tparam string _mapName The mapname
--
-- @treturn bool  True: Map has records
--               False: Map has no records
--
function MapRemover:mapHasRecords(_dataBase, _mapName, _mapTop)

  local mapTop = TableUtils:copy(_mapTop);
  mapTop:setMapName(_mapName);
  mapTop:loadRecords(_mapName);
  
  if (mapTop:getNumberOfRecords() == 0) then
    return false;
  else
    return true;
  end
  
end


return MapRemover;
