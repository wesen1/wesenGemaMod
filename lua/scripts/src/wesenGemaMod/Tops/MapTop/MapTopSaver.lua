---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

---
-- Handles saving records to the database.
--
MapTopSaver = {};


---
-- MapTopSaver constructor.
--
function MapTopSaver:__construct()

  local instance = {};
  setmetatable(instance, {__index = MapTopSaver});
    
  return instance;

end

---
-- Saves a single record to the database.
--
-- @param _record (Record) The record
-- @param _mapName (String) Map name
--
function MapTopSaver:addRecord(_record, _mapName)

  local player = _record:getPlayer();
  local mapId = Map:fetchMapId(_mapName);

  local sql = "SELECT records.id "
           .. "FROM records "
           .. "INNER JOIN players ON records.player = players.id "
           .. "INNER JOIN maps ON records.map = maps.id "
           .. "WHERE records.player = " .. player:getId() .. " "
           .. "AND maps.id = " .. mapId .. ";";
                        
  local result = dataBase:query(sql, true);
  
  if (#result == 0) then

    -- insert new record
    local sql = "INSERT INTO records "
             .. "(milliseconds, player, map) "
             .. "VALUES (" 
               .. _record:getMilliseconds() .. ","
               .. player:getId() .. ","
               .. mapId
             .. ");";
                              
    dataBase:query(sql, false);
             
  else
  
    local recordId = result[1].id;
  
    -- update existing record
    local sql = "UPDATE records "
             .. "SET milliseconds = " .. _record:getMilliseconds() .. " "
             .. "WHERE id = " .. recordId .. ";";
               
    dataBase:query(sql, false);
  
  end
  
end