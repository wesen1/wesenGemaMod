---
-- @author wesen
-- @copyright 2017-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Score = require "GemaScoreManager.Score.Score"

---
-- Contains the MapScore of a single player.
-- This includes the time needed to score, the weapon ID, the team ID and the creation timestamp.
--
-- @type MapScore
--
local MapScore = Score:extend()

---
-- The time that it took the player to score in milliseconds
--
-- @tfield int milliseconds
--
MapScore.milliseconds = nil

---
-- The ID of the weapon with which the player scored
--
-- @tfield int weaponId
--
MapScore.weaponId = nil

---
-- The ID of the team with which the player scored
--
-- @tfield int teamId
--
MapScore.teamId = nil

---
-- The unix timestamp at which the record was created
--
-- @tfield int createdAt
--
MapScore.createdAt = nil

---
-- The cached formatted time string of this MapScore
--
-- @tfield string timeString
--
MapScore.timeString = nil


---
-- MapScore constructor.
--
-- @tparam Player _player The Player to which the MapScore belongs
-- @tparam int _milliseconds The time that it took the player to score in milliseconds
-- @tparam int _weaponId The ID of the weapon with which the player scored
-- @tparam int _teamId The ID of the team with which the player scored
-- @tparam int _createdAt The unix timestamp at which this MapScore was created (Default: now)
-- @tparam int _rank The rank of the MapScore in the parent MapScoreList (optional)
--
function MapScore:new(_player, _milliseconds, _weaponId, _teamId, _createdAt, _rank)
  Score.new(self, _player, _rank)

  self.milliseconds = _milliseconds
  self.weaponId = _weaponId
  self.teamId = _teamId
  self.createdAt = _createdAt or os.time()
end


-- Getters and setters

---
-- Returns the time that it took the player to score in milliseconds.
--
-- @treturn int The time that it took the player to score in milliseconds
--
function MapScore:getMilliseconds()
  return self.milliseconds
end

---
-- Returns the ID of the weapon with which the player scored.
--
-- @treturn int The ID of the weapon with which the player scored
--
function MapScore:getWeaponId()
  return self.weaponId
end

---
-- Returns the ID of the team with which the player scored.
--
-- @treturn int The ID of the team with which the player scored
--
function MapScore:getTeamId()
  return self.teamId
end

---
-- Returns the unix timestamp at which this MapScore was created.
--
-- @treturn int The unix timestamp at which this MapScore was created
--
function MapScore:getCreatedAt()
  return self.createdAt
end

---
-- Returns the cached formatted time string.
--
-- @treturn string|nil The cached formatted time string
--
function MapScore:getTimeString()
  return self.timeString
end

---
-- Sets the cached formatted time string.
--
-- @tparam string _timeString The formatted time string
--
function MapScore:setTimeString(_timeString)
  self.timeString = _timeString
end


return MapScore
