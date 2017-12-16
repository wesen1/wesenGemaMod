---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

--
-- Handles removal of maps.
--
MapRemover = {};

--
-- Removes a map from the database and the maps folder.
--
-- @param String _mapName   Name of the map
--
-- @return bool  Success
--
function MapRemover:removeMap(_mapName)

  if (self:mapHasRecords(_mapName)) then
    return false;
  else

    local mapId = Map:fetchMapId(_mapName);

    -- remove map from database
    local sql = "DELETE FROM maps "
                 .. "WHERE id=" .. mapId .. ";";
    dataBase:query(sql, false);
  
    -- remove map files
    removemap(_mapName);
    
    return true;
    
  end

end

--
-- Returns whether a map has records.
--
-- @param String _mapName  The mapname
--
-- @return bool  True: Map has records
--               False: Map has no records
--
function MapRemover:mapHasRecords(_mapName)

  local maptop = MapTop:__construct();
  maptop:setMapName(_mapName);
  maptop:fetchRecords();
  
  if (maptop:getNumberOfRecords() == 0) then
    return false;
  else
    return true;
  end
  
end