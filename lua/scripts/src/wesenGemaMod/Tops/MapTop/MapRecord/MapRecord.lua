---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

local MapRecordPrinter = require("Tops/MapTop/MapRecord/MapRecordPrinter");

--
-- Stores information about a single record.
--
local MapRecord = {};


-- Class attributes

-- The player who created the record
MapRecord.player = "";

MapRecord.rank = -1;

-- Time needed to score in milliseconds
MapRecord.milliseconds = -1;

-- The record in a readable format (minutes:seconds,milliseconds)
MapRecord.displayString = "";

MapRecord.parentMapTop = "";

MapRecord.mapRecordPrinter = "";

--
-- Record constructor.
--
-- @param Player _player        Player object containing name and ip of the player who did the record
-- @param int _milliseconds     The time needed to finish the map
-- @param MapTop _parentMapTop  The parent MapTop
-- @param int _rank             Rank of the record in the maptop (if known)
--
function MapRecord:__construct(_player, _milliseconds, _parentMapTop, _rank)

  local instance = {};
  setmetatable(instance, {__index = MapRecord});

  instance.parentMapTop = _parentMapTop;
  instance.player = _player;
  instance.milliseconds = _milliseconds;
  instance.mapRecordPrinter = MapRecordPrinter:__construct(instance);
  instance.displayString = instance.mapRecordPrinter:generateTimeString();
  
  if (_rank == nil) then
    instance.rank = _parentMapTop:predictRank(_milliseconds);
  else
    instance.rank = _rank;
  end

  return instance;
  
end


-- Getters and Setters
function MapRecord:setPlayer(_player)
  self.player = _player;
end

function MapRecord:getPlayer()
  return self.player;
end

function MapRecord:setRank(_rank)
  self.rank = _rank;
end

function MapRecord:getRank()
  return self.rank;
end

function MapRecord:setMilliseconds(_milliseconds)
  self.milliseconds = _milliseconds;
end

function MapRecord:getMilliseconds()
  return self.milliseconds;
end

function MapRecord:setDisplayString(_displayString)
  self.displayString = _displayString;
end

function MapRecord:getDisplayString()
  return self.displayString;
end

function MapRecord:setParentMapTop(_parentMapTop)
  self.parentMapTop = _parentMapTop;
end

function MapRecord:getParentMapTop()
  return self.parentMapTop;
end


function MapRecord:printScoreRecord()
  self.mapRecordPrinter:printScoreRecord();
end


return MapRecord;
