---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"
local PlayerNameNotUniqueException = require "GemaScoreManager.Score.Exception.PlayerNameNotUniqueException"
local tablex = require "pl.tablex"

---
-- Represents a list of Score's for a single context (e.g. Score's per weapon).
--
-- @type ScoreList
--
local ScoreList = Object:extend()


---
-- Stores whether Score's are merged by player names
-- If true the player identifier that will be used per Score is the player name
-- If false the player identifier will be the player IP and name
--
-- @tfield bool mergeScoresByPlayerName
--
ScoreList.mergeScoresByPlayerName = nil

---
-- The list of Score's
-- This list is in the format { <Player Identifier> => <Score>, ... }
--
-- @tfield Score[] scores
--
ScoreList.scores = nil

---
-- The cached list of Player's per rank
-- This list is in the format { <Rank> => <Player Identifier>, ... }
--
-- @tfield string[] rankPlayerIdentifiers
--
ScoreList.rankPlayerIdentifiers = nil


---
-- ScoreList constructor.
--
-- @tparam bool _mergeScoresByPlayerName True to merge Score's by player names, false otherwise
--
function ScoreList:new(_mergeScoresByPlayerName)
  self.mergeScoresByPlayerName = _mergeScoresByPlayerName
  self.scores = {}
  self.rankPlayerIdentifiers = {}
end


-- Public Methods

---
-- Clears this ScoreList.
--
function ScoreList:clear()
  self.scores = {}
  self.rankPlayerIdentifiers = {}
end

---
-- Adds a Score to this ScoreList.
--
-- @tparam Score _score The Score to add
--
function ScoreList:addScore(_score)
  local playerIdentifier = self:fetchPlayerIdentifier(_score:getPlayer())

  self.scores[playerIdentifier] = _score
  self.rankPlayerIdentifiers[_score:getRank()] = playerIdentifier
end

---
-- Returns a Score for a given rank.
--
-- @tparam int _rank The rank to return a Score for
--
-- @treturn Score|nil The Score for the given rank
--
function ScoreList:getScoreByRank(_rank)
  local playerIdentifier = self.rankPlayerIdentifiers[_rank]
  if (playerIdentifier) then
    return self.scores[playerIdentifier]
  end
end

---
-- Returns the Score for a given Player.
--
-- @tparam Player _player The Player whose Score to return
--
-- @treturn Score|nil The Score for the given Player
--
function ScoreList:getScoreByPlayer(_player)
  local playerIdentifier = self:fetchPlayerIdentifier(_player)
  return self.scores[playerIdentifier]
end

---
-- Returns the Score for a Player with a given player name.
--
-- @tparam string _playerName The player name to search for
--
-- @treturn Score|nil The Score for the Player with the given name
--
-- @raise PlayerNameNotUniqueException if more than one Player with the given name exists in this list
--
function ScoreList:getScoreByPlayerName(_playerName)

  local matchingPlayers = self:getPlayersMatchingName(_playerName)
  if (#matchingPlayers == 1) then
    return self:getScoreByPlayer(matchingPlayers[1])
  elseif (#matchingPlayers > 1) then
    error(PlayerNameNotUniqueException("Score", _playerName, matchingPlayers))
  end

end

---
-- Returns the number of Score's that are currently stored inside this list.
--
-- @treturn int The number of Score's
--
function ScoreList:getNumberOfScores()
  return tablex.size(self.scores)
end

---
-- Refreshes the cached Player's per rank.
-- Must be called after the ranks of one or more Score's were modified.
--
function ScoreList:refreshRankScoreCache()
  self.rankPlayerIdentifiers = {}
  for playerIdentifier, score in pairs(self.scores) do
    self.rankPlayerIdentifiers[score:getRank()] = playerIdentifier
  end
end

---
-- Generates and returns a function that iterates over all Score's in this list sorted by ranks.
-- It can be used like `for rank, score in scoreList:iterateByRanks() do`.
--
-- @treturn function The iterator function
--
function ScoreList:iterateByRanks()

  local currentRank = 0
  local numberOfScores = self:getNumberOfScores()

  return function()
    currentRank = currentRank + 1
    if (currentRank <= numberOfScores) then
      return currentRank, self:getScoreByRank(currentRank)
    end
  end

end

---
-- Returns whether a given player name is unique in this ScoreList.
--
-- @tparam string _playerName The player name to search for
--
-- @treturn bool True if the given player name is unique in this ScoreList, false otherwise
--
function ScoreList:isPlayerNameUnique(_playerName)

  if (self.mergeScoresByPlayerName) then
    return true
  else
    -- Score's are not merged by player names, so the list of Player's needs to be checked for duplicated names
    return (#self:getPlayersMatchingName(_playerName, 2) <= 1)
  end

end


-- Protected Methods

---
-- Returns the player identifier to use for a given Player.
-- If mergeScoresByPlayerName is enabled "<player name>" will be returned.
-- If it is disabled "<player ip>_<player name>" will be returned.
--
-- @tparam Player _player The Player whose identifier to return
--
-- @treturn string The player identifier to use for the given Player
--
function ScoreList:fetchPlayerIdentifier(_player)

  if (self.mergeScoresByPlayerName) then
    return _player:getName()
  else
    return self:fetchUniquePlayerIdentifier(_player)
  end

end

---
-- Returns a unique player identifier for a given Player.
--
-- @tparam Player _player The Player whose unique identifier to return
--
-- @treturn string The unique player identifier for the given Player
--
function ScoreList:fetchUniquePlayerIdentifier(_player)
  return _player:getIp() .. "_" .. _player:getName()
end


-- Private Methods

---
-- Returns all Score Player's with a given player name.
--
-- @tparam string _playerName The name to search for
-- @tparam int _maximumNumberOfMatches The maximum number of matching Player's to return (optional)
--
-- @treturn Player[] The Score Player's that match the given name
--
function ScoreList:getPlayersMatchingName(_playerName, _maximumNumberOfMatches)

  local matchingPlayers = {}
  if (self.mergeScoresByPlayerName) then
    -- If Score's are merged by player names there is only up to one Player with the given name in this
    -- list, and his player identifier will be the given player name
    local playerScore = self.scores[_playerName]
    if (playerScore) then
      table.insert(matchingPlayers, playerScore:getPlayer())
    end

  else
    for _, score in pairs(self.scores) do
      if (score:getPlayer():getName() == _playerName) then
        table.insert(matchingPlayers, score:getPlayer())

        if (_maximumNumberOfMatches and #matchingPlayers >= _maximumNumberOfMatches) then
          break
        end
      end
    end

  end

  return matchingPlayers

end


return ScoreList
