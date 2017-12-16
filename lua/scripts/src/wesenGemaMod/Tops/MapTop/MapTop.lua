---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

require("MapTopCacher");
require("MapTopLoader");
require("MapTopPrinter");
require("MapTopSaver");

--
-- Handles the records of the current map.
--
MapTop = {};


-- @var String Name of the current map
MapTop.mapName = "";

-- @var MapTopCacher  Maptop Cacher for this maptop
MapTop.mapTopCacher = "";
MapTop.mapTopLoader = "";
MapTop.mapTopPrinter = "";
MapTop.mapTopSaver = "";


--
-- Maptop constructor.
--
function MapTop:__construct()

  local instance = {};
  setmetatable(instance, {__index = MapTop});
  
  instance.mapName = "";
  instance.mapTopCacher = MapTopCacher:__construct();
  instance.mapTopLoader = MapTopLoader:__construct(instance);
  instance.mapTopPrinter = MapTopPrinter:__construct(instance);
  instance.mapTopSaver = MapTopSaver:__construct();
  
  return instance;
  
end


-- Getters and Setters

function MapTop:getMapName()
  return self.mapName;
end

function MapTop:setMapName(_mapName)
  self.mapName = _mapName;
end

function MapTop:getMapTopCacher()
  return self.mapTopCacher;
end

function MapTop:setMapTopCacher(_mapTopCacher)
  self.mapTopCacher = _mapTopCacher;
end


--
-- Saves a record if it is better than the previous record of the player.
--
-- @param Record _newRecord   The record which will be checked
--
function MapTop:addRecord(_newRecord)
  
  local saveRecord = false;
  local playerRank = self:getRank(_newRecord:getPlayer():getName());
  
  if (playerRank == nil) then
    saveRecord = true;
    
  else
  
    local previousRecord = self:getRecord(playerRank);
  
    if (previousRecord:getMilliseconds() > _newRecord:getMilliseconds()) then
      saveRecord = true;
    end
    
  end
      
  if (saveRecord == true) then

    self.mapTopCacher:addRecord(_newRecord, playerRank, _newRecord:getRank());
    self.mapTopSaver:addRecord(_newRecord, self.mapName);
  end
    
end

--
-- Returns the rank of a specific player name.
--
-- @param string _name    Name of the player
--
-- @return int    Rank of the player or nil if no rank was found
--
function MapTop:getRank(_name)

  local record = self.mapTopCacher:getRecordByName(_name);

  if (record == nil) then
    return nil;
  else
    return record:getRank();
  end

end

--
-- Returns a single record of the record list.
--
-- @param int _rank   Rank of the record
--
function MapTop:getRecord(_rank)

  return self.mapTopCacher:getRecordByRank(_rank);
  
end

--
-- Returns the number of records in the maptop.
--
-- @return int Number records
--
function MapTop:getNumberOfRecords()

  return self.mapTopCacher:getNumberOfRecords();
  
end

--
-- Returns whether the maptop is empty.
--
-- @return bool  True: maptop is empty
--               False: maptop is not empty
--
function MapTop:isEmpty()

  if (self:getNumberOfRecords() == 0) then
    return true;
  else
    return false;
  end
  
end

--
-- Loads the records for a map from the database.
--
-- @param String _mapName  The map name
--
function MapTop:loadRecords(_mapName)

  self.mapTopCacher:setRecords({});
  self.mapTopCacher:setRecords(self.mapTopLoader:fetchRecords(_mapName));

end

--
-- Gets the rank for a specific time without changing the records list.
--
-- @param int _milliseconds   The record in milliseconds
--
-- @return int    The rank
--
function MapTop:predictRank(_milliseconds)

  for rank, record in ipairs(self.mapTopCacher:getRecords()) do
  
    if (record:getMilliseconds() > _milliseconds) then
      return rank;
    end
  
  end
  
  return self:getNumberOfRecords() + 1;

end

--
-- Prints statistics about the current map.
--
-- @param int _cn  Player to which the statistics will be printed
--
function MapTop:printMapStatistics(_cn)

  self.mapTopPrinter:printMapStatistics(_cn);
  
end

--
-- Prints the maptop to a player.
--
-- @param int _cn  Client number of the player
--
function MapTop:printMapTop(_cn)

  self.mapTopPrinter:printMapTop(_cn);
  
end