---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Handles maptop caching.
--
-- @type MapTopCacher
--
local MapTopCacher = {};


---
-- The list of cached records for one map
--
-- @tfield MapRecord[] records
--
MapTopCacher.records = {};

---
-- The parent map top
--
-- @tfield MapTop parentMapTop
--
MapTopCacher.parentMapTop = "";


---
-- MapTopCacher constructor.
--
-- @tparam MapTop _parentMapTop The parent map top
--
-- @treturn MapTopCacher The MapTopCacher instance
--
function MapTopCacher:__construct(_parentMapTop)

  local instance = {};
  setmetatable(instance, {__index = MapTopCacher});

  instance.records = {};
  instance.parentMapTop = _parentMapTop;

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

---
-- Returns the parent map top.
--
-- @treturn MapTop The parent map top
--
function MapTopCacher:getParentMapTop()
  return self.parentMapTop;
end

---
-- Sets the parent map top.
--
-- @tparam MapTop _parentMapTop The parent map top
--
function MapTopCacher:setParentMapTop(_parentMapTop)
  self.parentMapTop = _parentMapTop;
end


-- Class Methods

---
-- Inserts a new record into the cached record list.
--
-- @tparam MapRecord _newRecord The record which shall be added to the record list
-- @tparam int _currentRank The previous rank of the player who scored
--
function MapTopCacher:addRecord(_newRecord, _currentRank)

  local currentRank = -1;

  if (_currentRank == nil) then
    currentRank = self.parentMapTop:getNumberOfRecords() + 1;
  else
    currentRank = _currentRank;
  end

  self:removeRecordsWithPlayerName(_newRecord:getPlayer():getName());

  for i = currentRank - 1, _newRecord:getRank(), -1 do
    local record = self.records[i];
    record:setRank(i + 1);
    self.records[i + 1] = record;
  end

  self.records[_newRecord:getRank()] = _newRecord;

end

---
-- Removes all records with the player name _playerName from the cached records list.
--
-- @tparam string _playerName The player name
--
function MapTopCacher:removeRecordsWithPlayerName(_playerName)

  local recordWithPlayerName = -1;
  local numberOfRecords = self.parentMapTop:getNumberOfRecords();

  while (recordWithPlayerName ~= nil) do

    recordWithPlayerName = self:getRecordByName(_playerName);

    if (recordWithPlayerName ~= nil) then

      for i = recordWithPlayerName:getRank(), numberOfRecords, 1 do
        self.records[i] = self.records[i + 1];
      end
      self.records[numberOfRecords] = nil;

    end

  end

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
