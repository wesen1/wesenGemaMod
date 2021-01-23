---
-- @author wesen
-- @copyright 2020-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Score = require "GemaScoreManager.Score.Score"

---
-- Contains the ServerScore of a single player.
-- This includes points (based on completed maps), the number of best times and the total number of completed maps.
--
-- @type ServerScore
--
local ServerScore = Score:extend()

---
-- The amount of points
--
-- @tfield int points
--
ServerScore.points = nil

---
-- The number of best times (Rank 1 in a MapTop)
--
-- @tfield int numberOfBestTimes
--
ServerScore.numberOfBestTimes = nil

---
-- The total number of MapScore's (including the ones where the MapScore rank 1)
--
-- @tfield int numberOfMapScores
--
ServerScore.numberOfMapScores = nil


---
-- ServerScore constructor.
--
-- @tparam Player _player The Player to which the MapScore belongs
-- @tparam int _rank The initial rank of the ServerScore
--
function ServerScore:new(_player, _rank)
  Score.new(self, _player, _rank)

  self.points = 0
  self.numberOfBestTimes = 0
  self.numberOfMapScores = 0
end


-- Getters and Setters

---
-- Returns the amount of points.
--
-- @treturn int The amount of points
--
function ServerScore:getPoints()
  return self.points
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
-- Returns the total number of MapScore's.
--
-- @treturn int The total number of MapScore's
--
function ServerScore:getNumberOfMapScores()
  return self.numberOfMapScores
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
-- Increases the total number of MapScore's by 1.
--
function ServerScore:increaseNumberOfMapScores()
  self.numberOfMapScores = self.numberOfMapScores + 1
end


return ServerScore
