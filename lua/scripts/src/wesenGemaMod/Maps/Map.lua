---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

--
-- Stores information about the current map.
--
Map = {};

--
-- Fetches the map id from the database.
--
-- @param String _mapName  The map name
--
function Map:fetchMapId(_mapName)

  local mapName = dataBase:sanitize(_mapName);

  local sql = "SELECT id "
           .. "FROM maps "
           .. "WHERE name = BINARY '" .. mapName .. "';";
           
  local result = dataBase:query(sql, true);
  
  if (#result == 0) then
    return nil;
  else
    return tonumber(result[1].id);
  end

end

--
-- Saves the map name to the database.
--
-- @param String _mapName  The map name
--
function Map:saveMapName(_mapName)

  local mapName = dataBase:sanitize(_mapName);
  
  if (self:fetchMapId(_mapName) == nil) then
  
    local sql = "INSERT INTO maps "
             .. "(name) "
             .. "VALUES ('" .. mapName .. "');";
                              
    dataBase:query(sql, false);
    
  end

end