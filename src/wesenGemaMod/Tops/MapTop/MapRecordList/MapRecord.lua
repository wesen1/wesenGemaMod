---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Stores information about a single record.
--
-- @type MapRecord
--
local MapRecord = setmetatable({}, {});


---
-- The player who created the record
--
-- @tfield Player player
--
MapRecord.player = nil;

---
-- The rank of the record in the map top
--
-- @tfield int rank
--
MapRecord.rank = nil;

---
-- The time needed to score in milliseconds
--
-- @tfield int milliseconds
--
MapRecord.milliseconds = nil;

---
-- The weapon with which the player scored
--
-- @tfield int weapon
--
MapRecord.weapon = nil;

---
-- The team with which the player scored
--
-- @tfield int team
--
MapRecord.team = nil;

---
-- The unix timestamp at which the record was created
--
-- @tfield int createdAt
--
MapRecord.createdAt = nil;

---
-- The record in a readable format (minutes:seconds,milliseconds)
--
-- @tfield string displayString
--
MapRecord.timeString = nil;

---
-- The parent map record list
--
-- @tfield MapRecordList parentMapRecordList
--
MapRecord.parentMapRecordList = nil;

---
-- Stores whether this MapRecord is valid
-- MapRecords that are loaded from the database are always valid, only new MapRecord's may be invalid
--
-- @tfield bool isValid
--
MapRecord.isValid = nil


---
-- MapRecord constructor.
--
-- @tparam Player _player The player object containing name and ip of the player who did the record
-- @tparam int _milliseconds The time needed to finish the map
-- @tparam int _weapon The weapon id with which the player scored
-- @tparam int _team The team id with which the player scored
-- @tparam MapRecordList _parentMapRecordList The parent map record list
-- @tparam int _rank The rank of the record in the maptop (if known)
-- @tparam int _isValid True if the MapRecord is valid, false otherwise (Default: true)
--
-- @treturn MapRecord The MapRecord instance
--
function MapRecord:__construct(_player, _milliseconds, _weapon, _team, _parentMapRecordList, _rank, _isValid)

  local instance = setmetatable({}, {__index = MapRecord});

  instance.parentMapRecordList = _parentMapRecordList;
  instance.player = _player;
  instance.milliseconds = _milliseconds;
  instance.weapon = _weapon;
  instance.team = _team;
  instance.createdAt = os.time();
  instance.isValid = _isValid and true or false

  if (_rank == nil) then
    instance.rank = _parentMapRecordList:predictRank(_milliseconds);
  else
    instance.rank = _rank;
  end

  return instance;

end

getmetatable(MapRecord).__call = MapRecord.__construct;


---
-- Returns whether another map record is the same as this record.
--
-- @treturn bool True if the other map record is the same as this record, false otherwise
--
function MapRecord:equals(_mapRecord)

  if (self.player:equals(_mapRecord:getPlayer()) and
      self.milliseconds == _mapRecord:getMilliseconds() and
      self.weapon == _mapRecord:getWeapon() and
      self.team == _mapRecord:getTeam() and
      self.createdAt == _mapRecord:getCreatedAt()) then
    return true;
  else
    return false;
  end

end


-- Getters and setters

---
-- Returns the player.
--
-- @treturn Player The player
--
function MapRecord:getPlayer()
  return self.player;
end

---
-- Sets the player.
--
-- @tparam Player _player The player
--
function MapRecord:setPlayer(_player)
  self.player = _player;
end

---
-- Returns the rank.
--
-- @treturn int The rank
--
function MapRecord:getRank()
  return self.rank;
end

---
-- Sets the rank.
--
-- @tparam int _rank The rank
--
function MapRecord:setRank(_rank)
  self.rank = _rank;
end

---
-- Returns the milliseconds.
--
-- @treturn int The milliseconds
--
function MapRecord:getMilliseconds()
  return self.milliseconds;
end

---
-- Sets the milliseconds.
--
-- @tparam int _milliseconds The milliseconds
--
function MapRecord:setMilliseconds(_milliseconds)
  self.milliseconds = _milliseconds;
end

---
-- Returns the weapon id with which the player scored.
--
-- @treturn int The weapon id
--
function MapRecord:getWeapon()
  return self.weapon;
end

---
-- Sets the weapon id with which the player scored.
--
-- @tparam int _weapon The weapon id
--
function MapRecord:setWeapon(_weapon)
  self.weapon = _weapon;
end

---
-- Returns the team id with which the player scored.
--
-- @treturn int The team id
--
function MapRecord:getTeam()
  return self.team;
end

---
-- Sets the team id with which the player scored.
--
-- @tparam int _team The team id
--
function MapRecord:setTeam(_team)
  self.team = _team;
end

---
-- Returns the unix timestamp when the record was created.
--
-- @treturn int The unix timestamp
--
function MapRecord:getCreatedAt()
  return self.createdAt;
end

---
-- Sets the unix timestamp when the record was created.
--
-- @tparam int _createdAt The unix timestamp
--
function MapRecord:setCreatedAt(_createdAt)
  self.createdAt = _createdAt;
end

---
-- Returns the record in a readable format.
--
-- @treturn string The record in a readable format
--
function MapRecord:getTimeString()
  return self.timeString;
end

---
-- Sets the record in a readable format.
--
-- @tparam string _displayString The record in a readable format
--
function MapRecord:setTimeString(_timeString)
  self.timeString = _timeString;
end

---
-- Returns the parent map record list.
--
-- @treturn MapRecordList The parent map record list
--
function MapRecord:getParentMapRecordList()
  return self.parentMapRecordList;
end

---
-- Sets the parent map record list.
--
-- @tparam MapRecordList _parentMapRecordList The parent map record list
--
function MapRecord:setParentMapRecordList(_parentMapRecordList)
  self.parentMapRecordList = _parentMapRecordList;
end

---
-- Returns whether this MapRecord is valid.
--
-- @treturn bool True if this MapRecord is valid, false otherwise
--
function MapRecord:getIsValid()
  return self.isValid
end


return MapRecord;
