---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local MapHandler = require("Map/MapHandler");
local MapRecord = require("Tops/MapTop/MapRecordList/MapRecord");
local Player = require("Player/Player");

---
-- Loads the map records from the database.
--
-- @type MapTopLoader
--
local MapTopLoader = setmetatable({}, {});


---
-- MapTopLoader constructor.
--
-- @treturn MapTopLoader The MapTopLoader instance
--
function MapTopLoader:__construct()

  local instance = setmetatable({}, {__index = MapTopLoader});

  return instance;

end

getmetatable(MapTopLoader).__call = MapTopLoader.__construct;


-- Public Methods

---
-- Loads all records for a map from the database.
--
-- @tparam DataBase _dataBase The database
-- @tparam string _mapName The name of the map for which the records will be fetched
-- @tparam MapRecordList _mapRecordList The map record list into which the records will be saved
--
function MapTopLoader:fetchRecords(_dataBase, _mapName, _mapRecordList)

  _mapRecordList:clear();

  local mapId = MapHandler:fetchMapId(_dataBase, _mapName);
  if (not mapId) then
    return;
  end

  -- The records are grouped by name in order to avoid the same name appearing multiple times in the maptop
  local sql = "SELECT milliseconds, weapon_id, team_id, UNIX_TIMESTAMP(created_at) as created_at_timestamp, players.id, names.name, ips.ip " ..
              "FROM records " ..
              "INNER JOIN maps ON records.map = maps.id " ..
              "INNER JOIN players ON records.player = players.id " ..
              "INNER JOIN names ON players.name = names.id " ..
              "INNER JOIN ips ON players.ip = ips.id " ..
              "WHERE maps.id = " .. mapId .. " " ..
              "ORDER BY milliseconds ASC;";

  local result = _dataBase:query(sql, true);

  for index, row in ipairs(result) do

    local player = Player(-1, row.name, row.ip);
    player:setId(tonumber(row.id));

    local milliseconds = tonumber(row["milliseconds"]);
    local weapon_id = tonumber(row["weapon_id"]);
    local team_id = tonumber(row["team_id"]);
    local created_at = tonumber(row["created_at_timestamp"]);
    local record = MapRecord(player, milliseconds, weapon_id, team_id, _mapRecordList, index);
    record:setCreatedAt(created_at);

    _mapRecordList:addRecord(record);

  end

end


return MapTopLoader;
