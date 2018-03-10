---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local MapTopCacher = require("Tops/MapTop/MapTopCacher");
local MapTopLoader = require("Tops/MapTop/MapTopLoader");
local MapTopPrinter = require("Tops/MapTop/MapTopPrinter");
local MapTopSaver = require("Tops/MapTop/MapTopSaver");

---
-- @type MapTop Handles listing, printing and saving the records of the current map.
--
local MapTop = {};


---
-- The name of the current map
--
-- @tfield string mapName
--
MapTop.mapName = "";

---
-- The map top cacher
--
-- @tfield MapTopCacher mapTopCacher
--
MapTop.mapTopCacher = "";

---
-- The map top loader
--
-- @tfield MapTopLoader mapTopLoader
--
MapTop.mapTopLoader = "";

---
-- The map top printer
--
-- @tfield MapTopPrinter mapTopPrinter
--
MapTop.mapTopPrinter = "";

---
-- The map top saver
--
-- @tfield MapTopSaver mapTopSaver
--
MapTop.mapTopSaver = "";

---
-- The parent gema mod
--
-- @tfield GemaMod parentGemaMod
--
MapTop.parentGemaMod = "";


---
-- MapTop constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn MapTop The MapTop instance
--
function MapTop:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = MapTop});

  instance.mapName = "";
  instance.mapTopCacher = MapTopCacher:__construct();
  instance.mapTopLoader = MapTopLoader:__construct(instance);
  instance.mapTopPrinter = MapTopPrinter:__construct(instance);
  instance.mapTopSaver = MapTopSaver:__construct();
  instance.parentGemaMod = _parentGemaMod;

  return instance;

end


-- Getters and setters

---
-- Returns the map name.
--
-- @treturn string The map name
--
function MapTop:getMapName()
  return self.mapName;
end

---
-- Sets the map name.
--
-- @tparam string _mapName The map name
--
function MapTop:setMapName(_mapName)
  self.mapName = _mapName;
end

---
-- Returns the map top cacher.
--
-- @treturn MapTopCacher The map top cacher
--
function MapTop:getMapTopCacher()
  return self.mapTopCacher;
end

---
-- Sets the map top cacher.
--
-- @tparam MapTopCacher _mapTopCacher The map top cacher
--
function MapTop:setMapTopCacher(_mapTopCacher)
  self.mapTopCacher = _mapTopCacher;
end

---
-- Returns the map top loader.
--
-- @treturn MapTopLoader The map top loader
--
function MapTop:getMapTopLoader()
  return self.mapTopLoader;
end

---
-- Sets the map top loader.
--
-- @tparam MapTopLoader _mapTopLoader The map top loader
--
function MapTop:setMapTopLoader(_mapTopLoader)
  self.mapTopLoader = _mapTopLoader;
end

---
-- Returns the map top printer.
--
-- @treturn MapTopPrinter The map top printer
--
function MapTop:getMapTopPrinter()
  return self.mapTopPrinter;
end

---
-- Sets the map top printer.
--
-- @tparam MapTopPrinter _mapTopPrinter The map top printer
--
function MapTop:setMapTopPrinter(_mapTopPrinter)
  self.mapTopPrinter = _mapTopPrinter;
end

---
-- Returns the map top saver.
--
-- @treturn MapTopSaver The map top saver
--
function MapTop:getMapTopSaver()
  return self.mapTopSaver;
end

---
-- Sets the map top saver.
--
-- @tparam MapTopSaver _mapTopSaver The map top saver
--
function MapTop:setMapTopSaver(_mapTopSaver)
  self.mapTopSaver = _mapTopSaver;
end

---
-- Returns the parent gema mod.
--
-- @treturn GemaMod The parent gema mod
--
function MapTop:getParentGemaMod()
  return self.parentGemaMod;
end

---
-- Sets the parent gema mod.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
function MapTop:setParentGemaMod(_parentGemaMod)
  self.parentGemaMod = _parentGemaMod;
end


-- Class Methods

---
-- Saves a maprecord if it is better than the previous maprecord of the player.
--
-- @tparam MapRecord _newMapRecord The maprecord which will be checked
--
function MapTop:addRecord(_newMapRecord)

  local saveRecord = false;
  local playerRank = self:getRank(_newMapRecord:getPlayer():getName());

  if (playerRank == nil) then
    saveRecord = true;

  else

    local previousRecord = self:getRecord(playerRank);

    if (previousRecord:getMilliseconds() > _newMapRecord:getMilliseconds()) then
      saveRecord = true;
    end

  end

  if (saveRecord) then
    self.mapTopCacher:addRecord(_newMapRecord, playerRank);
    self.mapTopSaver:addRecord(self.parentGemaMod:getDataBase(), _newMapRecord, self.mapName);
  end

end

---
-- Returns the rank of a specific player name.
--
-- @tparam string _name The name of the player
--
-- @treturn int|nil The rank of the player or nil if no rank was found
--
function MapTop:getRank(_name)

  local record = self.mapTopCacher:getRecordByName(_name);

  if (record == nil) then
    return nil;
  else
    return record:getRank();
  end

end

---
-- Returns a single record of the record list.
--
-- @tparam int _rank The rank of the record
--
-- @treturn MapRecord The record
--
function MapTop:getRecord(_rank)
  return self.mapTopCacher:getRecordByRank(_rank);
end

---
-- Returns the number of records in the maptop.
--
-- @treturn int The number of records
--
function MapTop:getNumberOfRecords()
  return self.mapTopCacher:getNumberOfRecords();
end

---
-- Returns whether the maptop is empty.
--
-- @treturn bool True: The maptop is empty
--               False: The maptop is not empty
--
function MapTop:isEmpty()

  if (self:getNumberOfRecords() == 0) then
    return true;
  else
    return false;
  end

end

---
-- Loads the records for a map from the database.
--
-- @tparam string _mapName The map name
--
function MapTop:loadRecords(_mapName)

  local dataBase = self.parentGemaMod:getDataBase();

  self.mapTopCacher:setRecords({});
  self.mapTopCacher:setRecords(self.mapTopLoader:fetchRecords(dataBase, _mapName));

end

---
-- Gets the rank for a specific time without changing the records list.
--
-- @tparam int _milliseconds The record in milliseconds
--
-- @treturn int The rank
--
function MapTop:predictRank(_milliseconds)

  for rank, record in ipairs(self.mapTopCacher:getRecords()) do

    if (record:getMilliseconds() > _milliseconds) then
      return rank;
    end

  end

  return self:getNumberOfRecords() + 1;

end

---
-- Prints statistics about the current map.
--
-- @tparam int _cn The client number of the player to which the statistics will be printed
--
function MapTop:printMapStatistics(_cn)
  self.mapTopPrinter:printMapStatistics(_cn);
end

---
-- Prints the map top to a player.
--
-- @tparam int _cn  The client number of the player to which the map top will be printed
--
function MapTop:printMapTop(_cn)
  self.mapTopPrinter:printMapTop(_cn);
end


return MapTop;
