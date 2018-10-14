---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require("Util/Exception");
local MapHandler = require("Map/MapHandler");

---
-- Handles removing of maps.
--
-- @type MapRemover
--
local MapRemover = setmetatable({}, {});


---
-- MapRemover constructor.
--
-- @treturn MapRemover The MapRemover instance
--
function MapRemover:__construct()
  
  local instance = setmetatable({}, {__index = MapRemover});

  return instance;

end

getmetatable(MapRemover).__call = MapRemover.__construct;


-- Class Methods

---
-- Removes a map from the database and the maps folder if there are no records for that map.
--
-- @tparam DataBase _dataBase The database
-- @tparam string _mapName The name of the map
-- @tparam MapRotEditor _mapRotEditor The map rot editor
--
-- @raise Error when there are records for the map that shall be removed
--
function MapRemover:removeMap(_dataBase, _mapName, _mapRot)

  local mapId = MapHandler:fetchMapId(_mapName);

  if (self:mapHasRecords(_dataBase, mapId)) then
    error(Exception("Could not delete map \"" .. _mapName .. "\": There are map records for this map!"));
  else    

    -- Remove the map from the database
    local sql = "DELETE FROM maps "
             .. "WHERE id=" .. mapId .. ";";
    _dataBase:query(sql, false);

    -- Remove the map from the map rot
    _mapRot:removeMap(_mapName);

    -- Remove the map cgz and cfg files
    removemap(_mapName, _mapTop);

    return true;

  end

end

---
-- Returns whether there are records for a map.
--
-- @tparam DataBase _dataBase The database
-- @tparam int _mapId The map id
--
-- @treturn bool True if the map has records, false otherwise
--
function MapRemover:mapHasRecords(_dataBase, _mapId)

  local sql = "SELECT id FROM records "
           .. "WHERE map=" .. _mapId
           .. "LIMIT 1;";
  local result = _dataBase:query(sql, true);

  if (#result == 0) then
    return false;
  else
    return true;
  end

end


return MapRemover;
