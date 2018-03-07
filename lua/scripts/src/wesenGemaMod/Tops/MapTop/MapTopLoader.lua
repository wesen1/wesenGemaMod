---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

local Map = require("Maps/Map");
local MapRecord = require("Tops/MapTop/MapRecord/MapRecord");
local Player = require("Player");

--
-- Loads the maptop from the database.
--
local MapTopLoader = {};

MapTopLoader.parentMapTop = "";

--
-- MapTopLoader constructor.
--
-- @param MapTop _parentMapTop  The parent MapTop
--
function MapTopLoader:__construct(_parentMapTop)

  local instance = {};
  setmetatable(instance, {__index = MapTopLoader});
  
  instance.parentMapTop = _parentMapTop;
    
  return instance;

end

---
-- Loads all records for the current map from the database.
--
-- @param DataBase _dataBase The database
-- @param String _mapName Name of the map for which the records will be fetched
--
-- @return Record[]
--
function MapTopLoader:fetchRecords(_dataBase, _mapName)

  local sql = "SELECT milliseconds, players.id, names.name, ips.ip "
           .. "FROM records "
           .. "INNER JOIN maps ON records.map = maps.id "
           .. "INNER JOIN players ON records.player = players.id "
           .. "INNER JOIN names ON players.name = names.id "
           .. "INNER JOIN ips ON players.ip = ips.id "
           .. "WHERE maps.id = " .. Map:fetchMapId(_dataBase, _mapName) .. " "
           .. "ORDER BY milliseconds ASC;";
                                 
  local result = _dataBase:query(sql, true);
  local records = {};
  
  for index, row in ipairs(result) do
  
    local player = Player:__construct(row.name, row.ip);
    player:setId(row.id);
        
    local milliseconds = tonumber(row.milliseconds);
    local record = MapRecord:__construct(player, milliseconds, self.parentMapTop, index);
        
    table.insert(records, record);
    
  end
  
  return records;
    
end


return MapTopLoader;
