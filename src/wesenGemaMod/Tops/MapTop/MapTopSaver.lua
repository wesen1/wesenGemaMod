---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

--@todo: Replace by Map ORM class
local MapHandler = require("Map/MapHandler");

---
-- Handles saving records to the database.
--
-- @type MapTopSaver
--
local MapTopSaver = setmetatable({}, {});


---
-- MapTopSaver constructor.
--
-- @treturn MapTopSaver The MapTopSaver instance
--
function MapTopSaver:__construct()

  local instance = setmetatable({}, {__index = MapTopSaver});

  return instance;

end

getmetatable(MapTopSaver).__call = MapTopSaver.__construct;


-- Class Methods

---
-- Saves a single record to the database.
--
-- @tparam DataBase _dataBase The database
-- @tparam MapRecord _record The record
-- @tparam string _mapName The map name
--
function MapTopSaver:addRecord(_dataBase, _record, _mapName)

  -- TODO: Add players to database on demand (on map upload, on record)
  local player = _record:getPlayer();
  if (not player:getId()) then
    player:savePlayer();
  end

  local mapId = MapHandler:fetchMapId(_dataBase, _mapName);
  if (not mapId) then
    MapHandler:saveMapName(_dataBase, _mapName);
    mapId = MapHandler:fetchMapId(_dataBase, _mapName);
  end

  -- Check if the player has a record
  local selectExistingRecordsql = "SELECT records.id "
                               .. "FROM records "
                               .. "INNER JOIN players ON records.player = players.id "
                               .. "INNER JOIN maps ON records.map = maps.id "
                               .. "WHERE records.player = " .. player:getId() .. " "
                               .. "AND maps.id = " .. mapId .. ";";

  local result = _dataBase:query(selectExistingRecordsql, true);
  if (#result == 0) then

    -- insert new record
    local insertRecordsql = "INSERT INTO records "
                         .. "(milliseconds, player, map, weapon_id, team_id, created_at) "
                         .. "VALUES ("
                         .. _record:getMilliseconds() .. ","
                         .. player:getId() .. ","
                         .. mapId .. ","
                         .. _record:getWeapon() .. ","
                         .. _record:getTeam() .. ","
                         .. "FROM_UNIXTIME(" .. _record:getCreatedAt() .. ")"
                         .. ");";

    _dataBase:query(insertRecordsql, false);

  else

    local recordId = result[1].id;

    -- update existing record
    local updateRecordsql = "UPDATE records "
                         .. "SET "
                         .. "milliseconds = " .. _record:getMilliseconds() .. ","
                         .. "weapon_id = " .. _record:getWeapon() .. ","
                         .. "team_id = " .. _record:getTeam() .. ","
                         .. "created_at = FROM_UNIXTIME(" .. _record:getCreatedAt() .. ") "
                         .. "WHERE id = " .. recordId .. ";";

    _dataBase:query(updateRecordsql, false);

  end

end


return MapTopSaver;
