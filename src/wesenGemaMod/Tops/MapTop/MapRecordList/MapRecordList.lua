---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Stores the list of map records for a maptop and provides methods to add and get records.
--
-- @type MapRecordList
--
local MapRecordList = setmetatable({}, {});


---
-- The list of map records for one map ordered by rank
--
-- @tfield MapRecord[] records
--
MapRecordList.records = {};

---
-- The last player that was used in getRecordByPlayer()
--
-- @tfield string getRecordByPlayerLastPlayer
--
MapRecordList.getRecordByPlayerLastPlayer = nil;

---
-- The last player record that was the result of getRecordByPlayer()
--
-- @tfield MapRecord|nil getRecordByPlayerLastRecord
--
MapRecordList.getRecordByPlayerLastRecord = nil;


---
-- MapRecordList constructor.
--
-- @treturn MapRecordList The MapRecordList instance
--
function MapRecordList:__construct()

  local instance = setmetatable({}, {__index = MapRecordList});

  instance.records = {};

  return instance;

end

getmetatable(MapRecordList).__call = MapRecordList.__construct;


-- Getters and setters

---
-- Returns the list of map records.
--
-- @treturn MapRecord[] The list of map records
--
function MapRecordList:getRecords()
  return self.records;
end


-- Public Methods

-- Add entries to the list

---
-- Inserts a new record into the map record list.
--
-- @tparam MapRecord _newRecord The record which shall be added to the record list
--
function MapRecordList:addRecord(_newRecord)

  -- Get the current rank
  local currentRank = nil;

  local currentRecord = self:getRecordByPlayer(_newRecord:getPlayer());
  if (currentRecord) then
    currentRank = currentRecord:getRank();
    self.records[currentRank] = nil;
  else
    currentRank = self:getNumberOfRecords() + 1;
  end

  -- Move the records between the old rank and the new rank up by one rank
  for i = currentRank - 1, _newRecord:getRank(), -1 do
    local record = self.records[i];
    record:setRank(i + 1);
    self.records[i + 1] = record;
  end

  -- Insert the new record into the list of records
  self.records[_newRecord:getRank()] = _newRecord;

  -- Set the parent map record list of the new record
  _newRecord:setParentMapRecordList(self);

  -- Update the cached record
  if (self.getRecordByPlayerLastPlayer and self.getRecordByPlayerLastPlayer:equals(_newRecord:getPlayer())) then
    self.getRecordByPlayerLastRecord = _newRecord;
  end

end

---
-- Clears the map record list.
--
function MapRecordList:clear()
  self.getRecordByPlayerLastPlayer = nil;
  self.getReocrdByPlayerLastRecord = nil;
  self.records = {};
end


-- Fetch entries from the list

---
-- Returns a single record by rank.
--
-- @tparam int _rank The rank of the record
--
-- @treturn MapRecord|nil The map record or nil if no record with this rank exists
--
function MapRecordList:getRecordByRank(_rank)
  return self.records[_rank];
end

---
-- Returns the rank of a player in the list of map records.
--
-- @tparam Player _player The player
--
-- @treturn MapRecord|nil The map record or nil if no record was found
--
function MapRecordList:getRecordByPlayer(_player)

  -- Check if the cached record can be returned
  if (self.getRecordByPlayerLastPlayer and _player:equals(self.getRecordByPlayerLastPlayer)) then
    return self.getRecordByPlayerLastRecord;
  end

  for _, record in ipairs(self.records) do
    if (record:getPlayer():equals(_player)) then

      self.getRecordByPlayerLastPlayer = _player;
      self.getRecordByPlayerLastRecord = record;

      return record;

    end
  end

  return nil;

end


-- Fetch information about the list

---
-- Returns the number of records in the list of cached map records.
--
-- @treturn int The number of records
--
function MapRecordList:getNumberOfRecords()
  return #self.records;
end

---
-- Returns whether a map record is a personal best time of the player.
--
-- @tparam MapRecord The new map record
--
-- @treturn bool True if the map record is a personal best time, false otherwise
--
function MapRecordList:isPersonalBestTime(_mapRecord)

  local existingPlayerMapRecord = self:getRecordByPlayer(_mapRecord:getPlayer());
  if (existingPlayerMapRecord == nil or existingPlayerMapRecord:getMilliseconds() > _mapRecord:getMilliseconds()) then
    return true;
  else
    return false;
  end

end

---
-- Returns the rank of a specific player name.
--
-- @tparam Player _player The player
--
-- @treturn int|nil The rank of the player or nil if no rank was found
--
function MapRecordList:getPlayerRank(_player)

  local record = self:getRecordByPlayer(_player);

  if (record == nil) then
    return nil;
  else
    return record:getRank();
  end

end

---
-- Returns the rank for a specific time without changing the records list.
--
-- @tparam int _milliseconds The record in milliseconds
--
-- @treturn int The rank
--
function MapRecordList:predictRank(_milliseconds)

  local numberOfRecords = self:getNumberOfRecords();
  for rank = 1, numberOfRecords, 1 do

    local record = self.records[rank];
    if (record:getMilliseconds() > _milliseconds) then
      return rank;
    end

  end

  return numberOfRecords + 1;

end

---
-- Returns whether a player name is unique in the list of map records.
--
-- @tparam string _playerName The player name
--
-- @treturn bool True if the player name is unique in the list of map records, false otherwise
--
function MapRecordList:isPlayerNameUnique(_playerName)

  local counter = 0;
  for _, mapRecord in ipairs(self.records) do

    if (mapRecord:getPlayer():getName() == _playerName) then
      counter = counter + 1;
      if (counter > 1) then
        return false;
      end
    end

  end

  return true;

end


return MapRecordList;
