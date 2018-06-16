---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local MapRecordPrinter = require("Tops/MapTop/MapRecord/MapRecordPrinter");

---
-- Stores information about a single record.
--
-- @type MapRecord
--
local MapRecord = {};


---
-- The player who created the record
--
-- @tfield string player
--
MapRecord.player = "";

---
-- The rank of the record in the map top
--
-- @tfield int rank
--
MapRecord.rank = -1;

---
-- The time needed to score in milliseconds
--
-- @tfield int milliseconds
--
MapRecord.milliseconds = -1;

---
-- The weapon with which the player scored
--
-- @tfield int weapon
--
MapRecord.weapon = -1;

---
-- The team with which the player scored
--
-- @tfield int team
--
MapRecord.team = -1;

---
-- The unix timestamp at which the record was created
--
-- @tfield int createdAt
--
MapRecord.createdAt = "";

---
-- The record in a readable format (minutes:seconds,milliseconds)
-- This string is generated once on instance creation
--
-- @tfield string displayString
--
MapRecord.displayString = "";

---
-- The parent map top
--
-- @tfield MapTop parentMapTop
--
MapRecord.parentMapTop = "";

---
-- The map record printer
--
-- @tfield MapRecordPrinter mapRecordPrinter
--
MapRecord.mapRecordPrinter = "";


---
-- MapRecord constructor.
--
-- @tparam Player _player The player object containing name and ip of the player who did the record
-- @tparam int _milliseconds The time needed to finish the map
-- @tparam int _weapon The weapon id with which the player scored
-- @tparam int _team The team id with which the player scored
-- @tparam MapTop _parentMapTop The parent map top
-- @tparam int _rank The rank of the record in the maptop (if known)
--
-- @treturn MapRecord The MapRecord instance
--
function MapRecord:__construct(_player, _milliseconds, _weapon, _team, _parentMapTop, _rank)

  local instance = {};
  setmetatable(instance, {__index = MapRecord});

  instance.parentMapTop = _parentMapTop;
  instance.player = _player;
  instance.milliseconds = _milliseconds;
  instance.weapon = _weapon;
  instance.team = _team;
  instance.createdAt = os.time();
  instance.mapRecordPrinter = MapRecordPrinter:__construct(instance);
  instance.displayString = instance.mapRecordPrinter:generateTimeString();

  if (_rank == nil) then
    instance.rank = _parentMapTop:predictRank(_milliseconds);
  else
    instance.rank = _rank;
  end

  return instance;

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
function MapRecord:getDisplayString()
  return self.displayString;
end

---
-- Sets the record in a readable format.
--
-- @tparam string _displayString The record in a readable format
--
function MapRecord:setDisplayString(_displayString)
  self.displayString = _displayString;
end

---
-- Returns the parent map top.
--
-- @treturn MapTop The parent map top
--
function MapRecord:getParentMapTop()
  return self.parentMapTop;
end

---
-- Sets the parent map top.
--
-- @tparam MapTop _parentMapTop The parent map top
--
function MapRecord:setParentMapTop(_parentMapTop)
  self.parentMapTop = _parentMapTop;
end

---
-- Returns the maprecord printer.
--
-- @treturn MapRecordPrinter The maprecord printer
--
function MapRecord:getMapRecordPrinter()
  return self.mapRecordPrinter;
end

---
-- Sets the maprecord printer.
--
-- @tparam MapRecordPrinter _mapRecordPrinter The maprecord printer
--
function MapRecordPrinter:setMapRecordPrinter(_mapRecordPrinter)
  self.mapRecordPrinter = _mapRecordPrinter;
end


-- Class Methods

---
-- Prints the record to all clients when a player scores.
--
function MapRecord:printScoreRecord()
  self.mapRecordPrinter:printScoreRecord();
end


return MapRecord;
