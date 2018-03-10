---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TableUtils = require("Utils/TableUtils");

---
-- @type MapRemover Handles removal of maps.
--
local MapRemover = {};


-- Class Methods

---
-- Removes a map from the database and the maps folder if there are no records for that map.
--
-- @tparam DataBase _dataBase The database
-- @tparam string _mapName The name of the map
-- @tparam int _mapId The id of the map
-- @tparam MapTop _mapTop The map top
--
-- @treturn bool True: The map was successfully removed
--               False: The map was not removed
--
function MapRemover:removeMap(_dataBase, _mapName, _mapId, _mapTop)

  if (self:mapHasRecords(_dataBase, _mapName, _mapTop)) then
    return false;
  else

    -- remove map from database
    local sql = "DELETE FROM maps "
                 .. "WHERE id=" .. _mapId .. ";";
    _dataBase:query(sql, false);

    -- remove map files
    removemap(_mapName, _mapTop);

    return true;

  end

end

---
-- Returns whether there are records for a map.
--
-- @tparam DataBase _dataBase The database
-- @tparam string _mapName The mapname
-- @tparam MapTop _mapTop The map top
--
-- @treturn bool True: Map has records
--               False: Map has no records
--
function MapRemover:mapHasRecords(_dataBase, _mapName, _mapTop)

  local mapTop = TableUtils:copy(_mapTop);
  mapTop:setMapName(_mapName);
  mapTop:loadRecords(_mapName);

  if (mapTop:getNumberOfRecords() == 0) then
    return false;
  else
    return true;
  end

end


return MapRemover;
