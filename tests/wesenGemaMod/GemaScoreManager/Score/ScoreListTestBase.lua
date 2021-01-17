---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Base class for ScoreList class tests.
--
-- @type ScoreListTestBase
--
local ScoreListTestBase = TestCase:extend()


---
-- Checks that the a Score can be added to the ScoreList as expected.
--
function ScoreListTestBase:testCanAddScore()

  local playerMock = self:createPlayerMock()
  local scoreMock = self:createScoreMock()

  local scoreList = self:createScoreListInstance()

  self:expectScorePlayerIdentifierFetching(scoreMock, playerMock, "unarmed", "127.0.0.8")
      :and_also(
        scoreMock.getRank
                 :should_be_called()
                 :and_will_return(6)
      )
      :when(
        function()
          scoreList:addScore(scoreMock)

          local scoreByPlayerScore = scoreList:getScoreByPlayer(playerMock)
          self:assertIs(scoreByPlayerScore, scoreMock)

          local scoreByRankScore = scoreList:getScoreByRank(6)
          self:assertIs(scoreByRankScore, scoreMock)

        end
      )

end

---
-- Checks that a Score can be fetched for a given rank as expected.
--
function ScoreListTestBase:testCanReturnScoreByRank()

  local playerMockA = self:createPlayerMock()
  local playerMockB = self:createPlayerMock()
  local playerMockC = self:createPlayerMock()
  local scoreMockA = self:createScoreMock()
  local scoreMockB = self:createScoreMock()
  local scoreMockC = self:createScoreMock()

  local scoreList = self:createScoreListInstance()

  -- Add the scores to the ScoreList
  self:fillScoreList(
    scoreList,
    {
      { { playerMockA, "unarmed", "127.0.0.8" }, { scoreMockA, 1 } },
      { { playerMockB, "prooo", "127.0.0.9" }, { scoreMockB, 2 } },
      { { playerMockC, "fast", "127.0.0.10" }, { scoreMockC, 3 } }
    }
  )

  local scoreByRankScore
  scoreByRankScore = scoreList:getScoreByRank(1)
  self:assertIs(scoreMockA, scoreByRankScore)

  scoreByRankScore = scoreList:getScoreByRank(2)
  self:assertIs(scoreMockB, scoreByRankScore)

  scoreByRankScore = scoreList:getScoreByRank(3)
  self:assertIs(scoreMockC, scoreByRankScore)

  scoreByRankScore = scoreList:getScoreByRank(4)
  self:assertNil(scoreByRankScore)

  scoreByRankScore = scoreList:getScoreByRank(5)
  self:assertNil(scoreByRankScore)

  scoreByRankScore = scoreList:getScoreByRank(6)
  self:assertNil(scoreByRankScore)

end

---
-- Checks that a Score can be fetched for a given Player as expected.
--
function ScoreListTestBase:testCanReturnScoreByPlayer()

  local playerMockA = self:createPlayerMock()
  local playerMockB = self:createPlayerMock()
  local playerMockC = self:createPlayerMock()
  local playerMockD = self:createPlayerMock()
  local scoreMockA = self:createScoreMock()
  local scoreMockB = self:createScoreMock()
  local scoreMockC = self:createScoreMock()

  local scoreList = self:createScoreListInstance()

  -- Add the scores to the ScoreList
  self:fillScoreList(
    scoreList,
    {
      { { playerMockA, "first", "127.0.0.8" }, { scoreMockA, 1 } },
      { { playerMockB, "second", "127.0.0.9" }, { scoreMockB, 2 } },
      { { playerMockC, "slow", "127.0.0.10" }, { scoreMockC, 3 } }
    }
  )

  self:expectPlayerIdentifierFetching(playerMockA, "first", "127.0.0.8")
      :when(
        function()
          local scoreByPlayerScore = scoreList:getScoreByPlayer(playerMockA)
          self:assertIs(scoreByPlayerScore, scoreMockA)
        end
      )

  self:expectPlayerIdentifierFetching(playerMockB, "second", "127.0.0.9")
      :when(
        function()
          local scoreByPlayerScore = scoreList:getScoreByPlayer(playerMockB)
          self:assertIs(scoreByPlayerScore, scoreMockB)
        end
      )

  self:expectPlayerIdentifierFetching(playerMockC, "slow", "127.0.0.10")
      :when(
        function()
          local scoreByPlayerScore = scoreList:getScoreByPlayer(playerMockC)
          self:assertIs(scoreByPlayerScore, scoreMockC)
        end
      )

  self:expectPlayerIdentifierFetching(playerMockD, "unknown", "127.127.128.128")
      :when(
        function()
          local scoreByPlayerScore = scoreList:getScoreByPlayer(playerMockD)
          self:assertNil(scoreByPlayerScore)
        end
      )

end


---
-- Checks that the total number of Score's can be fetched as expected.
--
function ScoreListTestBase:testCanReturnNumberOfScores()

  local playerMockA = self:createPlayerMock()
  local playerMockB = self:createPlayerMock()
  local playerMockC = self:createPlayerMock()
  local scoreMockA = self:createScoreMock()
  local scoreMockB = self:createScoreMock()
  local scoreMockC = self:createScoreMock()

  local scoreList = self:createScoreListInstance()
  self:assertEquals(0, scoreList:getNumberOfScores())

  self:fillScoreList(
    scoreList,
    {
      { { playerMockA, "first", "127.0.0.8" }, { scoreMockA, 1 } }
    }
  )
  self:assertEquals(1, scoreList:getNumberOfScores())

  self:fillScoreList(
    scoreList,
    {
      { { playerMockB, "second", "127.0.0.9" }, { scoreMockB, 2 } }
    }
  )
  self:assertEquals(2, scoreList:getNumberOfScores())

  self:fillScoreList(
    scoreList,
    {
      { { playerMockC, "slow", "127.0.0.10" }, { scoreMockC, 3 } }
    }
  )
  self:assertEquals(3, scoreList:getNumberOfScores())

end

---
-- Checks that the ScoreList can be iterated sorted by ranks as expected.
--
function ScoreListTestBase:testCanBeIteratedByRanks()

  local playerMockA = self:createPlayerMock()
  local playerMockB = self:createPlayerMock()
  local playerMockC = self:createPlayerMock()
  local scoreMockA = self:createScoreMock()
  local scoreMockB = self:createScoreMock()
  local scoreMockC = self:createScoreMock()

  local scoreList = self:createScoreListInstance()

  -- Add the scores to the ScoreList
  self:fillScoreList(
    scoreList,
    {
      { { playerMockA, "first", "127.0.0.8" }, { scoreMockA, 1 } },
      { { playerMockB, "second", "127.0.0.9" }, { scoreMockB, 2 } },
      { { playerMockC, "slow", "127.0.0.10" }, { scoreMockC, 3 } }
    }
  )

  local result = {}
  for rank, score in scoreList:iterateByRanks() do
    table.insert(result, { rank, score })
  end

  local expectedResult = {
    { 1, scoreMockA },
    { 2, scoreMockB },
    { 3, scoreMockC }
  }

  self:assertEquals(expectedResult, result)

end


---
-- Checks that the cached Player's per ranks can be refreshed as expected.
--
function ScoreListTestBase:testCanRefreshRankScoresCache()

  local playerMockA = self:createPlayerMock()
  local playerMockB = self:createPlayerMock()
  local playerMockC = self:createPlayerMock()
  local scoreMockA = self:createScoreMock()
  local scoreMockB = self:createScoreMock()
  local scoreMockC = self:createScoreMock()

  local scoreList = self:createScoreListInstance()

  -- Add the scores to the ScoreList
  self:fillScoreList(
    scoreList,
    {
      { { playerMockA, "first", "127.0.0.8" }, { scoreMockA, 1 } },
      { { playerMockB, "second", "127.0.0.9" }, { scoreMockB, 2 } },
      { { playerMockC, "slow", "127.0.0.10" }, { scoreMockC, 3 } }
    }
  )

  -- Refresh the cached Score's per rank with changed ranks per Score
  scoreMockA.getRank
            :should_be_called()
            :and_will_return(2)
            :and_also(
              scoreMockB.getRank
                        :should_be_called()
                        :and_will_return(3)
            )
            :and_also(
              scoreMockC.getRank
                        :should_be_called()
                        :and_will_return(1)
            )
            :when(
              function()
                scoreList:refreshRankScoreCache()
              end
            )

  -- Size should still be 3
  self:assertEquals(3, scoreList:getNumberOfScores())

  local result = {}
  for rank, score in scoreList:iterateByRanks() do
    table.insert(result, { rank, score })
  end

  local expectedResult = {
    { 1, scoreMockC },
    { 2, scoreMockA },
    { 3, scoreMockB }
  }
  self:assertEquals(expectedResult, result)

  local scoreByRankScore
  scoreByRankScore = scoreList:getScoreByRank(1)
  self:assertIs(scoreByRankScore, scoreMockC)

  scoreByRankScore = scoreList:getScoreByRank(2)
  self:assertIs(scoreByRankScore, scoreMockA)

  scoreByRankScore = scoreList:getScoreByRank(3)
  self:assertIs(scoreByRankScore, scoreMockB)

end


---
-- Checks that Score's can be merged by player names as expected.
--
function ScoreListTestBase:testCanMergeScoresByPlayerName()

  local playerMockA = self:createPlayerMock()
  local playerMockB = self:createPlayerMock()
  local playerMockC = self:createPlayerMock()
  local scoreMockA = self:createScoreMock()

  local scoreList = self:createScoreListInstance(true)

  -- Add the scores to the ScoreList
  self:fillScoreList(
    scoreList,
    {
      { { playerMockA, "unarmed", "127.0.0.8" }, { scoreMockA, 1 } }
    }
  )

  self:assertEquals(1, scoreList:getNumberOfScores())
  self:expectPlayerIdentifierFetching(playerMockA, "unarmed", "127.0.0.8")
      :and_then(
        self:expectPlayerIdentifierFetching(playerMockB, "unarmed", "127.0.0.9")
      )
      :and_then(
        self:expectPlayerIdentifierFetching(playerMockC, "unarmed", "127.0.0.10")
      )
      :when(
        function()
          self:assertIs(scoreMockA, scoreList:getScoreByPlayer(playerMockA))
          self:assertIs(scoreMockA, scoreList:getScoreByPlayer(playerMockB))
          self:assertIs(scoreMockA, scoreList:getScoreByPlayer(playerMockC))
        end
      )

end

---
-- Checks that Score's can be merged by player ip + name combinations as expected.
--
function ScoreListTestBase:testCanMergeScoresByPlayerIpAndName()

  local playerMockA = self:createPlayerMock()
  local playerMockB = self:createPlayerMock()
  local playerMockC = self:createPlayerMock()
  local scoreMockA = self:createScoreMock()
  local scoreMockB = self:createScoreMock()
  local scoreMockC = self:createScoreMock()

  local scoreList = self:createScoreListInstance(false)

  -- Add the scores to the ScoreList
  self:fillScoreList(
    scoreList,
    {
      { { playerMockA, "tHePrO", "128.0.0.1" }, { scoreMockA, 1 } }
    }
  )

  self:assertEquals(1, scoreList:getNumberOfScores())
  self:expectPlayerIdentifierFetching(playerMockA, "tHePrO", "128.0.0.1")
      :and_then(
        self:expectPlayerIdentifierFetching(playerMockB, "tHePrO", "129.0.0.1")
      )
      :and_then(
        self:expectPlayerIdentifierFetching(playerMockC, "tHePrO", "130.0.0.1")
      )
      :when(
        function()
          self:assertIs(scoreMockA, scoreList:getScoreByPlayer(playerMockA))
          self:assertNil(scoreList:getScoreByPlayer(playerMockB))
          self:assertNil(scoreList:getScoreByPlayer(playerMockC))
        end
      )

  self:fillScoreList(
    scoreList,
    {
      { { playerMockB, "tHePrO", "129.0.0.1" }, { scoreMockB, 2 } }
    }
  )

  self:assertEquals(2, scoreList:getNumberOfScores())
  self:expectPlayerIdentifierFetching(playerMockA, "tHePrO", "128.0.0.1")
      :and_then(
        self:expectPlayerIdentifierFetching(playerMockB, "tHePrO", "129.0.0.1")
      )
      :and_then(
        self:expectPlayerIdentifierFetching(playerMockC, "tHePrO", "130.0.0.1")
      )
      :when(
        function()
          self:assertIs(scoreMockA, scoreList:getScoreByPlayer(playerMockA))
          self:assertIs(scoreMockB, scoreList:getScoreByPlayer(playerMockB))
          self:assertNil(scoreList:getScoreByPlayer(playerMockC))
        end
      )

  self:fillScoreList(
    scoreList,
    {
      { { playerMockC, "tHePrO", "130.0.0.1" }, { scoreMockC, 2 } }
    }
  )

  self:assertEquals(3, scoreList:getNumberOfScores())
  self:expectPlayerIdentifierFetching(playerMockA, "tHePrO", "128.0.0.1")
      :and_then(
        self:expectPlayerIdentifierFetching(playerMockB, "tHePrO", "129.0.0.1")
      )
      :and_then(
        self:expectPlayerIdentifierFetching(playerMockC, "tHePrO", "130.0.0.1")
      )
      :when(
        function()
          self:assertIs(scoreMockA, scoreList:getScoreByPlayer(playerMockA))
          self:assertIs(scoreMockB, scoreList:getScoreByPlayer(playerMockB))
          self:assertIs(scoreMockC, scoreList:getScoreByPlayer(playerMockC))
        end
      )

end


---
-- Checks that the ScoreList can tell whether a given player name is unique.
--
function ScoreListTestBase:testCanCheckIfPlayerNameIsUnique()

  local playerMockA = self:createPlayerMock()
  local playerMockB = self:createPlayerMock()
  local playerMockC = self:createPlayerMock()
  local scoreMockA = self:createScoreMock()
  local scoreMockB = self:createScoreMock()
  local scoreMockC = self:createScoreMock()

  local scoreListWithMergeScoresByNameEnabled = self:createScoreListInstance(true)

  -- Add the scores to the ScoreList
  self:fillScoreList(
    scoreListWithMergeScoresByNameEnabled,
    {
      { { playerMockA, "first", "127.0.0.8" }, { scoreMockA, 1 } },
      { { playerMockB, "second", "127.0.0.9" }, { scoreMockB, 2 } },
      { { playerMockC, "slow", "127.0.0.10" }, { scoreMockC, 3 } }
    }
  )

  self:assertTrue(scoreListWithMergeScoresByNameEnabled:isPlayerNameUnique("first"))
  self:assertTrue(scoreListWithMergeScoresByNameEnabled:isPlayerNameUnique("second"))
  self:assertTrue(scoreListWithMergeScoresByNameEnabled:isPlayerNameUnique("slow"))
  self:assertTrue(scoreListWithMergeScoresByNameEnabled:isPlayerNameUnique("unknown"))


  local scoreListWithMergeScoresByNameDisabled = self:createScoreListInstance(false)

  -- Add the scores to the ScoreList
  self:fillScoreList(
    scoreListWithMergeScoresByNameDisabled,
    {
      { { playerMockA, "first", "127.0.0.8" }, { scoreMockA, 1 } },
      { { playerMockB, "slow", "127.0.0.9" }, { scoreMockB, 2 } },
      { { playerMockC, "first", "127.0.0.10" }, { scoreMockC, 3 } },
    }
  )

  self:expectScorePlayerIdentifierFetching(scoreMockA, playerMockA, "first", "127.0.0.8")
      :and_also(
        self:expectScorePlayerIdentifierFetching(scoreMockB, playerMockB, "slow", "127.0.0.9")
      )
      :and_also(
        self:expectScorePlayerIdentifierFetching(scoreMockC, playerMockC, "first", "127.0.0.10")
      )
      :when(
        function()
          self:assertFalse(scoreListWithMergeScoresByNameDisabled:isPlayerNameUnique("first"))
          self:assertTrue(scoreListWithMergeScoresByNameDisabled:isPlayerNameUnique("slow"))
          self:assertTrue(scoreListWithMergeScoresByNameDisabled:isPlayerNameUnique("unknown"))
        end
      )

end

---
-- Checks that a Score can be fetched by a player name as expected.
--
function ScoreListTestBase:testCanReturnScoreByPlayerName()

  local playerMockA = self:createPlayerMock()
  local playerMockB = self:createPlayerMock()
  local playerMockC = self:createPlayerMock()
  local scoreMockA = self:createScoreMock()
  local scoreMockB = self:createScoreMock()
  local scoreMockC = self:createScoreMock()

  local scoreListWithMergeScoresByNameEnabled = self:createScoreListInstance(true)

  -- Add the scores to the ScoreList
  self:fillScoreList(
    scoreListWithMergeScoresByNameEnabled,
    {
      { { playerMockA, "first", "127.0.0.8" }, { scoreMockA, 1 } },
      { { playerMockB, "second", "127.0.0.9" }, { scoreMockB, 2 } },
      { { playerMockC, "slow", "127.0.0.10" }, { scoreMockC, 3 } }
    }
  )

  self:expectScorePlayerFetching(scoreMockA, playerMockA, true)
      :and_then(
        self:expectPlayerNameFetching(playerMockA, "first")
      )
      :and_also(
        self:expectScorePlayerFetching(scoreMockB, playerMockB, true)
            :and_then(
              self:expectPlayerNameFetching(playerMockB, "second")
            )
      )
      :and_also(
        self:expectScorePlayerFetching(scoreMockC, playerMockC, true)
            :and_then(
              self:expectPlayerNameFetching(playerMockC, "slow")
            )
      )
      :when(
        function()

          local scoreByPlayerNameScore
          scoreByPlayerNameScore = scoreListWithMergeScoresByNameEnabled:getScoreByPlayerName("first")
          self:assertIs(scoreByPlayerNameScore, scoreMockA)

          scoreByPlayerNameScore = scoreListWithMergeScoresByNameEnabled:getScoreByPlayerName("second")
          self:assertIs(scoreByPlayerNameScore, scoreMockB)

          scoreByPlayerNameScore = scoreListWithMergeScoresByNameEnabled:getScoreByPlayerName("slow")
          self:assertIs(scoreByPlayerNameScore, scoreMockC)

          scoreByPlayerNameScore = scoreListWithMergeScoresByNameEnabled:getScoreByPlayerName("unknown")
          self:assertNil(scoreByPlayerNameScore)

        end
      )


  local scoreListWithMergeScoresByNameDisabled = self:createScoreListInstance(false)

  -- Add the scores to the ScoreList
  self:fillScoreList(
    scoreListWithMergeScoresByNameDisabled,
    {
      { { playerMockA, "first", "127.0.0.8" }, { scoreMockA, 1 } },
      { { playerMockB, "first", "127.0.0.9" }, { scoreMockB, 2 } },
      { { playerMockC, "slow", "127.0.0.10" }, { scoreMockC, 3 } }
    }
  )

  self:expectScorePlayerIdentifierFetching(scoreMockA, playerMockA, "first", "127.0.0.8")
      :and_also(
        self:expectScorePlayerIdentifierFetching(scoreMockB, playerMockB, "first", "127.0.0.9")
      )
      :and_also(
        self:expectScorePlayerIdentifierFetching(scoreMockC, playerMockC, "slow", "127.0.0.10")
      )
      :when(
        function()

          local scoreByPlayerNameScore

          -- Finds exactly one player, should work
          scoreByPlayerNameScore = scoreListWithMergeScoresByNameDisabled:getScoreByPlayerName("slow")
          self:assertIs(scoreByPlayerNameScore, scoreMockC)

          -- Finds exactly zero players, should work
          scoreByPlayerNameScore = scoreListWithMergeScoresByNameEnabled:getScoreByPlayerName("unknown")
          self:assertNil(scoreByPlayerNameScore)

          -- Finds more than one player, should throw an Exception
          local PlayerNameNotUniqueException = require "GemaScoreManager.Score.Exception.PlayerNameNotUniqueException"
          local status, result = pcall(function()
              scoreListWithMergeScoresByNameDisabled:getScoreByPlayerName("first")
          end)

          self:assertFalse(status)
          self:assertTrue(result:is(PlayerNameNotUniqueException))

          self:assertEquals("Score", result:getFetchedInformationName())
          self:assertEquals("first", result:getPlayerName())

          local matchingPlayers = result:getMatchingPlayers()
          self:assertEquals(2, #matchingPlayers)
          if (playerMockA == matchingPlayers[1]) then
            self:assertIs(playerMockA, matchingPlayers[1])
            self:assertIs(playerMockB, matchingPlayers[2])
          else
            self:assertIs(playerMockA, matchingPlayers[2])
            self:assertIs(playerMockB, matchingPlayers[1])
          end

        end
      )

end


---
-- Checks that the ScoreList can be cleared as expected.
--
function ScoreListTestBase:testCanBeCleared()

  local playerMockA = self:createPlayerMock()
  local playerMockB = self:createPlayerMock()
  local playerMockC = self:createPlayerMock()
  local scoreMockA = self:createScoreMock()
  local scoreMockB = self:createScoreMock()
  local scoreMockC = self:createScoreMock()

  local scoreList = self:createScoreListInstance()

  -- Add the scores to the ScoreList
  self:fillScoreList(
    scoreList,
    {
      { { playerMockA, "first", "127.0.0.8" }, { scoreMockA, 1 } },
      { { playerMockB, "second", "127.0.0.9" }, { scoreMockB, 2 } },
      { { playerMockC, "slow", "127.0.0.10" }, { scoreMockC, 3 } }
    }
  )

  self:assertEquals(3, scoreList:getNumberOfScores())

  scoreList:clear()
  self:assertEquals(0, scoreList:getNumberOfScores())

  local result = {}
  for rank, score in scoreList:iterateByRanks() do
    table.insert(result, { rank, score })
  end

  self:assertEquals({}, result)
  self:assertNil(scoreList:getScoreByRank(1))
  self:assertNil(scoreList:getScoreByRank(2))
  self:assertNil(scoreList:getScoreByRank(3))

  self:expectPlayerIdentifierFetching(playerMockA, "first", "127.0.0.8")
      :and_also(
        self:expectPlayerIdentifierFetching(playerMockB, "second", "127.0.0.9")
      )
      :and_also(
        self:expectPlayerIdentifierFetching(playerMockC, "slow", "127.0.0.10")
      )
      :when(
        function()
          self:assertNil(scoreList:getScoreByPlayer(playerMockA))
          self:assertNil(scoreList:getScoreByPlayer(playerMockB))
          self:assertNil(scoreList:getScoreByPlayer(playerMockC))

          self:assertNil(scoreList:getScoreByPlayerName("first"))
          self:assertNil(scoreList:getScoreByPlayerName("second"))
          self:assertNil(scoreList:getScoreByPlayerName("slow"))
        end
      )

end


-- Protected Methods

---
-- Creates and returns a ScoreList instance.
--
-- @tparam bool _mergeScoresByPlayerName The mergeScoresByPlayerName setting to create the ScoreList with
--
-- @treturn ScoreList The created ScoreList instance
--
function ScoreListTestBase:createScoreListInstance(_mergeScoresByPlayerName)
end

---
-- Creates and returns a Score mock.
--
-- @treturn Score The created Score mock
--
function ScoreListTestBase:createScoreMock()
end

---
-- Creates and returns a Player mock.
--
-- @treturn Player The created Player mock
--
function ScoreListTestBase:createPlayerMock()

  return {
    getIp = self.mach.mock_method("getIpMock"),
    getName = self.mach.mock_method("getNameMock")
  }

end


---
-- Adds given Score's to a given ScoreList.
--
-- @tparam ScoreList _scoreList The ScoreList to add Score's to
-- @tparam table _scoresToAdd The config for the Score's that should be added to the ScoreList
--
function ScoreListTestBase:fillScoreList(_scoreList, _scoresToAdd)

  for _, scoreToAdd in ipairs(_scoresToAdd) do

    local playerData = scoreToAdd[1]
    local scoreData = scoreToAdd[2]

    local playerMock = playerData[1]
    local playerName = playerData[2]
    local playerIp = playerData[3]

    local scoreMock = scoreData[1]
    local scoreRank = scoreData[2]

    self:expectScorePlayerIdentifierFetching(scoreMock, playerMock, playerName, playerIp)
        :and_also(
          scoreMock.getRank
                   :should_be_called()
                   :and_will_return(scoreRank)
        )
        :when(
          function()
            _scoreList:addScore(scoreMock)
          end
        )

  end

end


---
-- Generates and returns the expectations for a Score Player fetching.
--
-- @tparam Score _scoreMock The Score mock whose Player is expected to be fetched
-- @tparam Player _playerMock The Player mock to return
-- @tparam bool _anyNumberOfTimes True to allow any amount of Score Player fetchings
--
-- @treturn table The generated expectations
--
function ScoreListTestBase:expectScorePlayerFetching(_scoreMock, _playerMock, _anyNumberOfTimes)

  local expectation
  if (_anyNumberOfTimes) then
    expectation = _scoreMock.getPlayer
                            :may_be_called()
                            :multiple_times(10)
  else
    expectation = _scoreMock.getPlayer
                            :should_be_called()
  end

  return expectation:and_will_return(_playerMock)

end

---
-- Generates and returns the expectations for a Player name fetching.
--
-- @tparam Player _playerMock The Player whose name is expected to be fetched
-- @tparam string _name The name to return
--
-- @treturn table The generated expectations
--
function ScoreListTestBase:expectPlayerNameFetching(_playerMock, _name)

  return _playerMock.getName
                    :should_be_called()
                    :and_will_return(_name)

end

---
-- Generates and returns the expectations for zero or more Player identifier fetchings.
--
-- @tparam Player _playerMock The Player whose identifier is expected to be fetched
-- @tparam string _name The name to return
-- @tparam string _ip The IP to return
--
-- @treturn table The generated expectations
--
function ScoreListTestBase:expectPlayerIdentifierFetching(_playerMock, _name, _ip)

  return _playerMock.getName
                    :may_be_called()
                    :multiple_times(10)
                    :and_will_return(_name)
                    :and_also(
                      _playerMock.getIp
                                 :may_be_called()
                                 :multiple_times(10)
                                 :and_will_return(_ip)
                    )

end

---
-- Generates and returns the expectations for zero or more Score Player identifier fetchings.
--
-- @tparam Score _scoreMock The Score mock whose Player identifier is expected to be fetched
-- @tparam Player _playerMock The Player whose identifier is expected to be fetched
-- @tparam string _name The name to return
-- @tparam string _ip The IP to return
--
-- @treturn table The generated expectations
--
function ScoreListTestBase:expectScorePlayerIdentifierFetching(_scoreMock, _playerMock, _name, _ip)

  return self:expectScorePlayerFetching(_scoreMock, _playerMock, true)
             :and_also(
               self:expectPlayerIdentifierFetching(_playerMock, _name, _ip)
             )

end


return ScoreListTestBase
