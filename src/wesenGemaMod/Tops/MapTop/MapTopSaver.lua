---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local MapHandler = require("Maps/MapHandler");

---
-- Handles saving records to the database.
--
-- @type MapTopSaver
--
local MapTopSaver = {};


---
-- MapTopSaver constructor.
--
-- @treturn MapTopSaver The MapTopSaver instance
--
function MapTopSaver:__construct()

  local instance = {};
  setmetatable(instance, {__index = MapTopSaver});

  return instance;

end


-- Class Methods

---
-- Saves a single record to the database.
--
-- @tparam DataBase _dataBase The database
-- @tparam MapRecord _record The record
-- @tparam string _mapName The map name
--
function MapTopSaver:addRecord(_dataBase, _record, _mapName)

  local player = _record:getPlayer();
  local mapId = MapHandler:fetchMapId(_dataBase, _mapName);

  local sql = "SELECT records.id "
           .. "FROM records "
           .. "INNER JOIN players ON records.player = players.id "
           .. "INNER JOIN maps ON records.map = maps.id "
           .. "WHERE records.player = " .. player:getId() .. " "
           .. "AND maps.id = " .. mapId .. ";";

  local result = _dataBase:query(sql, true);

  if (#result == 0) then

    -- insert new record
    local sql = "INSERT INTO records "
             .. "(milliseconds, player, map, weapon_id, team_id, created_at) "
             .. "VALUES (" 
               .. _record:getMilliseconds() .. ","
               .. player:getId() .. ","
               .. mapId .. ","
               .. _record:getWeapon() .. ","
               .. _record:getTeam() .. ","
               .. "FROM_UNIXTIME(" .. _record:getCreatedAt() .. ")"
             .. ");";

    _dataBase:query(sql, false);

  else

    local recordId = result[1].id;

    -- update existing record
    local sql = "UPDATE records "
             .. "SET "
             .. "milliseconds = " .. _record:getMilliseconds() .. ","
             .. "weapon_id = " .. _record:getWeapon() .. ","
             .. "team_id = " .. _record:getTeam() .. ","
             .. "created_at = FROM_UNIXTIME(" .. _record:getCreatedAt() .. ") "
             .. "WHERE id = " .. recordId .. ";";

    _dataBase:query(sql, false);

  end

end


return MapTopSaver;
