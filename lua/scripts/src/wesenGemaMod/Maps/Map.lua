---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local MapRemover = require("Maps/MapRemover");

---
-- @type Map Provides functions to add and remove maps.
--
local Map = {};


-- Class Methods

---
-- Fetches the map id from the database.
--
-- @tparam DataBase _dataBase The database
-- @tparam string _mapName The map name
--
-- @treturn int|nil The map id or nil if the map id was not found
--
function Map:fetchMapId(_dataBase, _mapName)

  local mapName = _dataBase:sanitize(_mapName);

  local sql = "SELECT id "
           .. "FROM maps "
           .. "WHERE name = BINARY '" .. mapName .. "';";

  local result = _dataBase:query(sql, true);

  if (#result == 0) then
    return nil;
  else
    return tonumber(result[1].id);
  end

end

---
-- Saves the map name to the database.
--
-- @tparam DataBase _dataBase The database
-- @tparam string _mapName The map name
--
function Map:saveMapName(_dataBase, _mapName)

  local mapName = _dataBase:sanitize(_mapName);

  if (self:fetchMapId(_dataBase, _mapName) == nil) then

    local sql = "INSERT INTO maps "
             .. "(name) "
             .. "VALUES ('" .. mapName .. "');";

    _dataBase:query(sql, false);

  end

end

---
-- Tries to remove a map from the database and the packages folder.
--
-- @tparam DataBase _dataBase The database
-- @tparam string _mapName The map name
-- @tparam MapTop _mapTop The map top
--
function Map:removeMap(_dataBase, _mapName, _mapTop)

  local success = MapRemover:removeMap(_dataBase, _mapName, self:fetchMapId(_dataBase, _mapName), _mapTop);

  if (not success) then
    Output:print(Output:getColor("error") .. "Error: Could not remove the map '" .. _mapName .. '"');
  end

end


return Map;
