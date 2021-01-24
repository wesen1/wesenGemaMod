---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ScoreList = require "GemaScoreManager.Score.ScoreList"

---
-- Represents a list of MapScore's for a single context (e.g. MapScore's per weapon).
--
-- @type MapScoreList
--
local MapScoreList = ScoreList:extend()

---
-- The MapScore's that are hidden from outputs
-- This list is in the format { <Unique Player Identifier> => <MapScore>, ... }
--
-- @tfield MapScore[] hiddenMapScores
--
MapScoreList.hiddenMapScores = nil


---
-- MapScoreList constructor.
--
-- @tparam bool _mergeScoresByPlayerName True to merge Score's by player names, false otherwise
--
function MapScoreList:new(_mergeScoresByPlayerName)
  ScoreList.new(self, _mergeScoresByPlayerName)
  self.hiddenMapScores = {}
end


-- Public Methods

---
-- Clears this MapScoreList.
--
function MapScoreList:clear()
  ScoreList.clear(self)
  self.hiddenMapScores = {}
end


---
-- Adds a hidden MapScore to this list.
--
-- @tparam MapScore _mapScore The hidden MapScore to add
--
function MapScoreList:addHiddenMapScore(_mapScore)
  self.hiddenMapScores[self:fetchUniquePlayerIdentifier(_mapScore:getPlayer())] = _mapScore
end

---
-- Removes a hidden MapScore from this list.
--
-- @tparam Player _player The Player whose hidden MapScore to remove
--
function MapScoreList:removeHiddenMapScore(_player)
  self.hiddenMapScores[self:fetchUniquePlayerIdentifier(_player)] = nil
end

---
-- Returns the hidden MapScore for a given Player.
--
-- @tparam Player _player The Player whose hidden MapScore to return
--
-- @treturn MapScore|nil The hidden MapScore for the given Player
--
function MapScoreList:getHiddenMapScoreByPlayer(_player)
  return self.hiddenMapScores[self:fetchUniquePlayerIdentifier(_player)]
end


---
-- Returns the number of rank MapScore's that have lower or equal milliseconds like a
-- given number of milliseconds.
--
-- @tparam int _milliseconds The number of milliseconds to compare the MapScore's to
--
-- @treturn int The number of rank MapScore's with lower or equal milliseconds like the given number of milliseconds
--
function MapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(_milliseconds)

  for rank, mapScore in self:iterateByRanks() do
    if (mapScore:getMilliseconds() > _milliseconds) then
      return rank - 1
    end
  end

  return self:getNumberOfScores()

end


return MapScoreList
