---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"
local ServerScore = require "Tops.ServerTop.ServerScore"

---
-- Manages the list of ServerScore's for a single ServerTop.
--
-- @type ServerScoreList
--
local ServerScoreList = Object:extend()

---
-- The MapRankPointsProvider that will be used to calculate the amount of points for new added MapRecord's
--
-- @tfield MapRankPointsProvider mapRankPointsProvider
--
ServerScoreList.mapRankPointsProvider = nil

---
-- The list of ServerScore's
--
-- @tfield ServerScore[] scores
--
ServerScoreList.scores = nil


---
-- ServerScoreList constructor.
--
-- @tparam MapRankPointsProvider _mapRankPointsProvider The MapRankPointsProvider to use
--
function ServerScoreList:new(_mapRankPointsProvider)
  self.mapRankPointsProvider = _mapRankPointsProvider
  self.scores = {}
end


-- Getters and Setters

---
-- Returns the list of ServerScore's.
--
-- @treturn ServerScore[] The list of ServerScore's
--
function ServerScoreList:getScores()
  return self.scores
end


-- Public Methods

---
-- Initializes this ServerScoreList with a given list of ServerScore's.
-- The list is expected to be in the format { <rank> => ServerScore, ... }.
--
-- @tparam ServerScore[] _scores The ServerScore's to initialize this ServerScoreList with
--
function ServerScoreList:initialize(_scores)
  self.scores = _scores
end


---
-- Processes a given MapRecord and changes the ServerScore points accordingly.
--
-- @tparam MapRecord _mapRecord The MapRecord to process
-- @tparam int|nil _previousMapRank The previous map rank that was replaced by the MapRecord
-- @tparam MapRecordList _mapRecordList The MapRecordList to which the MapRecord was added
--
function ServerScoreList:processMapRecord(_mapRecord, _previousMapRank, _mapRecordList)

  local playerScore = self:getScoreByPlayer(_mapRecord:getPlayer())

  -- Process the points
  local mapRecordPoints = self:calculateMapRankPoints(_mapRecord:getRank())
  if (playerScore) then
    playerScore:addPoints(mapRecordPoints)
    if (_previousMapRank ~= nil) then
      playerScore:subtractPoints(self:calculateMapRankPoints(_previousMapRank))

      for _, mapRecord in ipairs(_mapRecordList:getRecords()) do
        if (mapRecord:getRank() > _mapRecord:getRank()) then
          local oldMapRecordPoints = self:calculateMapRankPoints(mapRecord:getRank() - 1)
          local newMapRecordPoints = self:calculateMapRankPoints(mapRecord:getRank())

          if (oldMapRecordPoints > newMapRecordPoints) then
            self:getScoreByPlayer(mapRecord:getPlayer()):subtractPoints(oldMapRecordPoints - newMapRecordPoints)
          end
        end
      end

      if (_mapRecord:getRank() == 1 and _previousMapRank ~= 1) then
        local oldBestTimePlayer = _mapRecordList:getRecordByRank(2):getPlayer()
        self:getScoreByPlayer(oldBestTimePlayer):decreaseNumberOfBestTimes()
      end

    end

  else
    playerScore = ServerScore(_mapRecord:getPlayer(), mapRecordPoints, self:getNumberOfScores() + 1)
    table.insert(self.scores, playerScore)
  end

  -- Process the number of map scores
  if (_previousMapRank == nil) then
    playerScore:increaseNumberOfMapRecords()
  end
  if (_mapRecord:getRank() == 1) then
    playerScore:increaseNumberOfBestTimes()
  end

  -- Sort the list of ServerScore's by points
  table.sort(
    self.scores,
    function(_playerScoreA, _playerScoreB)
      return (_playerScoreA:getPoints() > _playerScoreB:getPoints())
    end
  )

  for rank, playerScore in ipairs(self.scores) do
    playerScore:setRank(rank)
  end

end

---
-- Calculates and returns the points for a given map rank.
--
-- @tparam int _mapRank The map rank to calculate the amount of points for
--
-- @treturn int The amount of points for the given map rank
--
function ServerScoreList:calculateMapRankPoints(_mapRank)
  return self.mapRankPointsProvider:getPointsForMapRank(_mapRank)
end

---
-- Clears this ServerScoreList.
--
function ServerScoreList:clear()
  self.scores = {}
end


---
-- Returns a ServerScore for a given ServerTop rank.
--
-- @tparam int _rank The rank whose ServerScore to return
--
-- @treturn ServerScore|nil The ServerScore for the given rank
--
function ServerScoreList:getScoreByRank(_rank)
  return self.scores[_rank]
end

---
-- Returns a ServerScore for a given Player.
--
-- @tparam Player _player The Player whose ServerScore to return
--
-- @treturn ServerScore|nil The ServerScore for the given Player
--
function ServerScoreList:getScoreByPlayer(_player)

  for _, score in ipairs(self.scores) do
    if (score:getPlayer():equals(_player)) then
      return score
    end
  end

end

---
-- Returns the number of ServerScore's that are stored inside this list.
--
-- @treturn int The number of ServerScore's
--
function ServerScoreList:getNumberOfScores()
  return #self.scores
end

---
-- Returns the rank of a given Player.
--
-- @tparam Player _player The Player whose rank to return
--
-- @treturn int|nil The rank of the given Player
--
function ServerScoreList:getPlayerRank(_player)

  local score = self:getScoreByPlayer(_player)
  if (score) then
    return score:getRank()
  end

end

---
-- Returns whether a given player name is unique in this ServerScoreList.
--
-- @tparam string _playerName The player name to search for
--
-- @treturn bool True if the given player name is unique in this ServerScoreList, false otherwise
--
function ServerScoreList:isPlayerNameUnique(_playerName)

  local numberOfNameOccurrences = 0
  for _, score in ipairs(self.scores) do

    if (score:getPlayer():getName() == _playerName) then
      numberOfNameOccurrences = numberOfNameOccurrences + 1
      if (numberOfNameOccurrences > 1) then
        return false
      end
    end

  end

  return true

end


return ServerScoreList
