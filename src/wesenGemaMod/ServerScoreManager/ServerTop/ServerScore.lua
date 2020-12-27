---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Contains the ServerScore of a single player.
-- This includes points (based on completed maps), the number of best times and the total number of completed maps.
--
-- @type ServerScore
--
local ServerScore = Object:extend()

---
-- The Player to which this ServerScore belongs
--
-- @tfield Player player
--
ServerScore.player = nil

---
-- The amount of points
--
-- @tfield int points
--
ServerScore.points = nil

---
-- The rank of this ServerScore in the parent ServerTop
--
-- @tfield int rank
--
ServerScore.rank = nil

---
-- The number of best times (Rank 1 in a map top)
--
-- @tfield int numberOfBestTimes
--
ServerScore.numberOfBestTimes = nil

---
-- The total number of map records (including the ones where the record is a best time)
--
-- @tfield int numberOfMapRecords
--
ServerScore.numberOfMapRecords = nil


---
-- ServerScore constructor.
--
-- @tparam Player _player The Player to which the ServerScore belongs
-- @tparam int _points The initial amount of points
-- @tparam int _rank The initial rank of this ServerScore
--
function ServerScore:new(_player, _points, _rank)
  self.player = _player
  self.points = _points
  self.rank = _rank
  self.numberOfBestTimes = 0
  self.numberOfMapRecords = 0
end


-- Getters and Setters

---
-- Returns the Player to which the ServerScore belongs.
--
-- @treturn Player The Player
--
function ServerScore:getPlayer()
  return self.player
end

---
-- Returns the amount of points.
--
-- @treturn int The amount of points
--
function ServerScore:getPoints()
  return self.points
end

---
-- Returns the rank of this ServerScore in the parent ServerScoreList.
--
-- @treturn int The rank
--
function ServerScore:getRank()
  return self.rank
end

---
-- Sets the rank of this ServerScore.
--
-- @tparam int _rank The rank to set
--
function ServerScore:setRank(_rank)
  self.rank = _rank
end

---
-- Returns the number of best times.
--
-- @treturn int The number of best times
--
function ServerScore:getNumberOfBestTimes()
  return self.numberOfBestTimes
end

---
-- Returns the total number of map records.
--
-- @treturn int The total number of map records
--
function ServerScore:getNumberOfMapRecords()
  return self.numberOfMapRecords
end


-- Public Methods

---
-- Adds points to this ServerScore.
--
-- @tparam int _points The amount of points to add
--
function ServerScore:addPoints(_points)
  self.points = self.points + _points
end

---
-- Subtracts points from this ServerScore.
--
-- @tparam int _points The amount of points to subtract
--
function ServerScore:subtractPoints(_points)
  self.points = self.points - _points
end

---
-- Increases the number of best times by 1.
--
function ServerScore:increaseNumberOfBestTimes()
  self.numberOfBestTimes = self.numberOfBestTimes + 1
end

---
-- Decreases the number of best times by 1.
--
function ServerScore:decreaseNumberOfBestTimes()
  self.numberOfBestTimes = self.numberOfBestTimes - 1
end

---
-- Increases the total number of map records by 1.
--
function ServerScore:increaseNumberOfMapRecords()
  self.numberOfMapRecords = self.numberOfMapRecords + 1
end


return ServerScore
