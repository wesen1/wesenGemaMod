---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local MapRecordList = require("Tops/MapTop/MapRecordList/MapRecordList");
local MapTopLoader = require("Tops/MapTop/MapTopLoader");
local MapTopSaver = require("Tops/MapTop/MapTopSaver");

---
-- Handles listing, loading and saving the records of the current map.
--
-- @type MapTop
--
local MapTop = setmetatable({}, {});


---
-- The name of the last map for which the map top was initialized
--
-- @tfield string lastMapName
--
MapTop.lastMapName = nil;

---
-- The map record list
--
-- @tfield MapRecordList mapRecordList
--
MapTop.mapRecordList = nil;

---
-- The map top loader
--
-- @tfield MapTopLoader mapTopLoader
--
MapTop.mapTopLoader = nil;

---
-- The map top saver
--
-- @tfield MapTopSaver mapTopSaver
--
MapTop.mapTopSaver = nil;


---
-- MapTop constructor.
--
-- @treturn MapTop The MapTop instance
--
function MapTop:__construct()

  local instance = setmetatable({}, {__index = MapTop});

  instance.mapRecordList = MapRecordList();
  instance.mapTopLoader = MapTopLoader();
  instance.mapTopSaver = MapTopSaver();

  return instance;

end

getmetatable(MapTop).__call = MapTop.__construct;


-- Getters and setters

---
-- Returns the name of the last map for which the map top was initialized.
--
-- @treturn string The map name
--
function MapTop:getLastMapName()
  return self.lastMapName
end

---
-- Returns the map record list.
--
-- @treturn MapRecordList The map record list
--
function MapTop:getMapRecordList()
  return self.mapRecordList;
end


-- Public Methods

---
-- Saves a maprecord if it is better than the previous maprecord of the player.
--
-- @tparam MapRecord _newMapRecord The maprecord which will be checked
--
function MapTop:addRecord(_newMapRecord)

  if (self.mapRecordList:isPersonalBestTime(_newMapRecord)) then
    self.mapRecordList:addRecord(_newMapRecord);
    self.mapTopSaver:addRecord(_newMapRecord, self.lastMapName);
  end

end

---
-- Loads the records for a map from the database.
--
-- @tparam string _mapName The map name
--
function MapTop:loadRecords(_mapName)

  if (self.lastMapName ~= _mapName) then
    self.lastMapName = _mapName;
    self.mapTopLoader:fetchRecords(_mapName, self.mapRecordList);
  end

end


return MapTop;
