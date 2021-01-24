---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ServerScore = require "GemaScoreManager.ServerScore.ServerScore"
local ScoreList = require "GemaScoreManager.Score.ScoreList"
local tablex = require "pl.tablex"

---
-- Represents a list of ServerScore's for a single context (e.g. ServerScore's per weapon).
--
-- @type ServerScoreList
--
local ServerScoreList = ScoreList:extend()


-- Public Methods

---
-- Fetches the ServerScore for a given Player.
-- If no ServerScore for the Player exists yet it will be created on the fly.
--
-- @tparam Player _player The Player whose ServerScore to return
--
-- @treturn ServerScore The ServerScore for the given Player
--
function ServerScoreList:getOrCreateScore(_player)

  local existingServerScore = self:getScoreByPlayer(_player)
  if (existingServerScore) then
    return existingServerScore
  else
    self:addScore(ServerScore(_player, self:getNumberOfScores() + 1))
    return self:getScoreByPlayer(_player)
  end

end

---
-- Sorts all ServerScore's by points and refreshes the ServerScore ranks cache.
--
function ServerScoreList:sortScores()

  local indexedScores = tablex.values(self.scores)
  table.sort(
    indexedScores,
    function(_scoreA, _scoreB)
      return (_scoreA:getPoints() > _scoreB:getPoints())
    end
  )

  for rank, score in ipairs(indexedScores) do
    score:setRank(rank)
  end

  self:refreshRankScoreCache()

end


return ServerScoreList
