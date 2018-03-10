---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- @type MapTopCacher Handles maptop caching.
--
local MapTopCacher = {};

---
-- The list of cached records for one map
--
-- @tfield MapRecord[] records
--
MapTopCacher.records = {};


---
-- MapTopCacher constructor.
--
-- @treturn MapTopCacher The MapTopCacher instance
--
function MapTopCacher:__construct()

  local instance = {};
  setmetatable(instance, {__index = MapTopCacher});

  instance.records = {};

  return instance;

end


-- Getters and setters

---
-- Returns the list of cached records.
--
-- @treturn MapRecord[] The list of cached records
--
function MapTopCacher:getRecords()
  return self.records;
end

---
-- Sets the list of cached records.
--
-- @tparam MapRecord[] _records The list of cached records
--
function MapTopCacher:setRecords(_records)
  self.records = _records;
end


-- Class Methods

---
-- Inserts a new record into the cached record list.
--
-- @tparam MapRecord _newRecord The record which shall be added to the record list
-- @tparam int _currentRank The previous rank of the player who scored
--
function MapTopCacher:addRecord(_newRecord, _currentRank)

  if (_currentRank ~= nil) then
    table.remove(self.records, _currentRank);
  end

  table.insert(self.records, _newRecord:getRank(), _newRecord);

end

---
-- Returns a single record.
--
-- @tparam int _rank The rank of the record
--
function MapTopCacher:getRecordByRank(_rank)
  return self.records[_rank];
end

---
-- Returns the rank of a player in the list of cached maprecords.
--
-- @tparam string _name The player name
--
-- @treturn MapRecord|nil The maprecord or nil if no record was found
--
function MapTopCacher:getRecordByName(_name)

  for rank, record in ipairs(self.records) do

    if (record:getPlayer():getName() == _name) then
      return record;
    end

  end

  return nil;

end

---
-- Returns the number of records in the list of cached maprecords.
--
-- @treturn int The number of records
--
function MapTopCacher:getNumberOfRecords()
  return #self.records;
end


return MapTopCacher;
