---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

--
-- Handles maptop caching.
--
MapTopCacher = {};

---
--  @field records (table) Cached list of records for the current map
--  
MapTopCacher.records = {};

--
-- MapTopCacher constructor.
--
function MapTopCacher:__construct()

  local instance = {};
  setmetatable(instance, {__index = MapTopCacher});
  
  instance.records = {};
  
  return instance;

end


-- Getters and setters

function MapTopCacher:getRecords()
  return self.records;
end

function MapTopCacher:setRecords(_records)
  self.records = _records;
end


-- Inserts a new record into the cached record list.
--
-- @param Record _newRecord   The record which shall be added to the record list
-- @param int _currentRank    The previous rank of the player who scored
-- @param int _newRank        Rank of the new record
--
function MapTopCacher:addRecord(_newRecord, _currentRank, _newRank)

  if (_currentRank ~= nil) then
    table.remove(self.records, _currentRank);
  end
  
  table.insert(self.records, _newRank, _newRecord);
    
end

--
-- Returns a single record.
--
-- @param int _rank  Rank of the record
--
function MapTopCacher:getRecordByRank(_rank)

  return self.records[_rank];

end

--
-- Returns the rank of a player on the map.
--
-- @param String _name  Player name of the record
--
-- @return Record The record
--
function MapTopCacher:getRecordByName(_name)

  for rank, record in ipairs(self.records) do
    
    if (record:getPlayer():getName() == _name) then
      return record;
    end

  end
  
  return nil;

end

--
-- Returns the number of records in the cached maptop.
--
-- @return int Number of records
--
function MapTopCacher:getNumberOfRecords()

  return #self.records;

end