---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Map = require("Maps/Map");
local MapRecord = require("Tops/MapTop/MapRecord/MapRecord");
local Player = require("Player/Player");

---
-- Loads the map records from the database.
--
-- @type MapTopLoader
--
local MapTopLoader = {};


---
-- The parent map top
--
-- @tfield MapTop parentMapTop
--
MapTopLoader.parentMapTop = "";


---
-- MapTopLoader constructor.
--
-- @tparam MapTop _parentMapTop The parent MapTop
--
-- @treturn MapTopLoader The MapTopLoader instance
--
function MapTopLoader:__construct(_parentMapTop)

  local instance = {};
  setmetatable(instance, {__index = MapTopLoader});

  instance.parentMapTop = _parentMapTop;

  return instance;

end


-- Getters and setters

---
-- Returns the parent map top.
--
-- @treturn MapTop The parent map top
--
function MapTopLoader:getParentMapTop()
  return self.parentMapTop;
end

---
-- Sets the parent map top.
--
-- @tparam MapTop _parentMapTop The parent map top
--
function MapTopLoader:setParentMapTop(_parentMapTop)
  self.parentMapTop = _parentMapTop;
end


-- Class Methods

---
-- Loads all records for a map from the database.
--
-- @tparam DataBase _dataBase The database
-- @tparam string _mapName The name of the map for which the records will be fetched
--
-- @treturn MapRecord[]
--
function MapTopLoader:fetchRecords(_dataBase, _mapName)

  local mapId = Map:fetchMapId(_dataBase, _mapName);

  if (not mapId) then
    return {};
  end

  -- The records are grouped by name in order to avoid the same name appearing multiple times in the maptop
  local sql = "SELECT milliseconds, weapon_id, team_id, UNIX_TIMESTAMP(created_at) as created_at_timestamp, players.id, names.name, ips.ip "
           .. "FROM records "
           .. "INNER JOIN maps ON records.map = maps.id "
           .. "INNER JOIN players ON records.player = players.id "
           .. "INNER JOIN names ON players.name = names.id "
           .. "INNER JOIN ips ON players.ip = ips.id "
           .. "WHERE maps.id = " .. mapId .. " "
           .. "ORDER BY milliseconds ASC;";

  local result = _dataBase:query(sql, true);
  local records = {};

  for index, row in ipairs(result) do

    local player = Player:__construct(row.name, row.ip);
    player:setId(row.id);

    local milliseconds = tonumber(row["milliseconds"]);
    local weapon_id = tonumber(row["weapon_id"]);
    local team_id = tonumber(row["team_id"]);
    local created_at = tonumber(row["created_at_timestamp"]);
    local record = MapRecord:__construct(player, milliseconds, weapon_id, team_id, self.parentMapTop, index);
    record:setCreatedAt(created_at);

    table.insert(records, record);

  end

  return records;

end


return MapTopLoader;
