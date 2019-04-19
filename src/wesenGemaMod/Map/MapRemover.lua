---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require("Util/Exception");
local Map = require("ORM/Models/Map")
local MapRecord = require("ORM/Models/MapRecord")
local TextTemplate = require("Output/Template/TextTemplate");

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
-- @tparam string _mapName The name of the map
-- @tparam MapRotEditor _mapRotEditor The map rot editor
--
-- @raise Error when there are records for the map that shall be removed
--
function MapRemover:removeMap(_mapName, _mapRot)

  local map = Map:get()
                 :filterByName(_mapName)
                 :findOne()

  if (map) then

    if (self:mapHasRecords(map)) then
      error(Exception(
          TextTemplate(
            "ExceptionMessages/MapRemover/MapRecordsExistForDeleteMap",
            { ["mapName"] = _mapName }
          )
      ));
    else
      map:delete()
    end

  end

  -- Remove the map from the map rot
  _mapRot:removeMap(_mapName);

  -- Remove the map cgz and cfg files
  removemap(_mapName);

end

---
-- Returns whether there are records for a map.
--
-- @tparam int _mapId The map id
--
-- @treturn bool True if the map has records, false otherwise
--
function MapRemover:mapHasRecords(_map)

  local mapRecord = MapRecord:get()
                             :filterByMapId(_map.id)
                             :findOne()
  return (mapRecords == nil)

end


return MapRemover;
