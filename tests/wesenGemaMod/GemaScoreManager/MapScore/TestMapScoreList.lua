---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ScoreListTestBase = require "wesenGemaMod.GemaScoreManager.Score.ScoreListTestBase"

---
-- Checks that the MapScoreList works as expected.
--
-- @type TestMapScoreList
--
local TestMapScoreList = ScoreListTestBase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestMapScoreList.testClassPath = "GemaScoreManager.MapScore.MapScoreList"


---
-- Checks that hidden MapScore's can be added and removed as expected.
--
function TestMapScoreList:testCanManageHiddenMapScores()

  local playerMockA = self:createPlayerMock()
  local playerMockB = self:createPlayerMock()
  local playerMockC = self:createPlayerMock()
  local mapScoreMockA = self:createScoreMock()
  local mapScoreMockB = self:createScoreMock()
  local mapScoreMockC = self:createScoreMock()

  local mapScoreList = self:createScoreListInstance(true)

  self:expectScorePlayerIdentifierFetching(mapScoreMockA, playerMockA, "first", "127.0.0.8")
      :and_also(
        self:expectScorePlayerIdentifierFetching(mapScoreMockB, playerMockB, "second", "127.0.0.9")
      )
      :and_also(
        self:expectScorePlayerIdentifierFetching(mapScoreMockC, playerMockC, "slow", "127.0.0.10")
      )
      :when(
        function()

          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockA))
          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockB))
          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockC))

          -- Add a hidden MapScore
          mapScoreList:addHiddenMapScore(mapScoreMockA)
          self:assertIs(mapScoreMockA, mapScoreList:getHiddenMapScoreByPlayer(playerMockA))
          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockB))
          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockC))

          -- Add another hidden MapScore
          mapScoreList:addHiddenMapScore(mapScoreMockB)
          self:assertIs(mapScoreMockA, mapScoreList:getHiddenMapScoreByPlayer(playerMockA))
          self:assertIs(mapScoreMockB, mapScoreList:getHiddenMapScoreByPlayer(playerMockB))
          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockC))

          -- Add another hidden MapScore
          mapScoreList:addHiddenMapScore(mapScoreMockC)
          self:assertIs(mapScoreMockA, mapScoreList:getHiddenMapScoreByPlayer(playerMockA))
          self:assertIs(mapScoreMockB, mapScoreList:getHiddenMapScoreByPlayer(playerMockB))
          self:assertIs(mapScoreMockC, mapScoreList:getHiddenMapScoreByPlayer(playerMockC))

          -- Remove a hidden MapScore
          mapScoreList:removeHiddenMapScore(playerMockA)
          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockA))
          self:assertIs(mapScoreMockB, mapScoreList:getHiddenMapScoreByPlayer(playerMockB))
          self:assertIs(mapScoreMockC, mapScoreList:getHiddenMapScoreByPlayer(playerMockC))

          -- Remove another hidden MapScore
          mapScoreList:removeHiddenMapScore(playerMockB)
          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockA))
          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockB))
          self:assertIs(mapScoreMockC, mapScoreList:getHiddenMapScoreByPlayer(playerMockC))

          -- Remove the last hidden MapScore
          mapScoreList:removeHiddenMapScore(playerMockC)
          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockA))
          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockB))
          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockC))

        end
      )

end

---
-- Checks that the hidden MapScore's are cleared when the MapScoreList is cleared.
--
function TestMapScoreList:testClearsHiddenMapScoresOnClear()

  local playerMockA = self:createPlayerMock()
  local playerMockB = self:createPlayerMock()
  local playerMockC = self:createPlayerMock()
  local mapScoreMockA = self:createScoreMock()
  local mapScoreMockB = self:createScoreMock()
  local mapScoreMockC = self:createScoreMock()

  local mapScoreList = self:createScoreListInstance(true)

  self:expectScorePlayerIdentifierFetching(mapScoreMockA, playerMockA, "first", "127.0.0.8")
      :and_also(
        self:expectScorePlayerIdentifierFetching(mapScoreMockB, playerMockB, "second", "127.0.0.9")
      )
      :and_also(
        self:expectScorePlayerIdentifierFetching(mapScoreMockC, playerMockC, "slow", "127.0.0.10")
      )
      :when(
        function()

          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockA))
          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockB))
          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockC))

          mapScoreList:addHiddenMapScore(mapScoreMockA)
          mapScoreList:addHiddenMapScore(mapScoreMockB)
          mapScoreList:addHiddenMapScore(mapScoreMockC)
          self:assertIs(mapScoreMockA, mapScoreList:getHiddenMapScoreByPlayer(playerMockA))
          self:assertIs(mapScoreMockB, mapScoreList:getHiddenMapScoreByPlayer(playerMockB))
          self:assertIs(mapScoreMockC, mapScoreList:getHiddenMapScoreByPlayer(playerMockC))

          mapScoreList:clear()
          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockA))
          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockB))
          self:assertNil(mapScoreList:getHiddenMapScoreByPlayer(playerMockC))

        end
      )

end


---
-- Checks that the number of ranks with less than or equal milliseconds like a given limit
-- is returned as expected.
--
function TestMapScoreList:testCanReturnNumberOfRanksWithLessThanOrEqualMillisecondsLikeGivenLimit()

  local playerMockA = self:createPlayerMock()
  local playerMockB = self:createPlayerMock()
  local playerMockC = self:createPlayerMock()
  local mapScoreMockA = self:createScoreMock()
  local mapScoreMockB = self:createScoreMock()
  local mapScoreMockC = self:createScoreMock()

  local mapScoreList = self:createScoreListInstance()

  -- MapScoreList is empty, there should be 0 MapScore's with lower milliseconds
  self:assertEquals(0, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(16321))
  self:assertEquals(0, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(100))
  self:assertEquals(0, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(1000000))

  -- Add a MapScore with higher milliseconds
  self:fillScoreList(
    mapScoreList,
    {
      { { playerMockA, "first", "127.0.0.8" }, { mapScoreMockA, 1 } }
    }
  )

  mapScoreMockA.getMilliseconds
               :should_be_called()
               :multiple_times(6)
               :and_will_return(20000)
               :when(
                 function()
                   self:assertEquals(0, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(3000))
                   self:assertEquals(0, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(16321))
                   self:assertEquals(0, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(19999))
                   self:assertEquals(1, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(20000))
                   self:assertEquals(1, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(20001))
                   self:assertEquals(1, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(24000))
                 end
               )

  -- Add two MapScore's with lower milliseconds and refresh the rank Score cache
  self:fillScoreList(
    mapScoreList,
    {
      { { playerMockB, "second", "127.0.0.9" }, { mapScoreMockB, 1 } },
      { { playerMockC, "slow", "127.0.0.10" }, { mapScoreMockC, 2 } }
    }
  )
  mapScoreMockA.getRank
               :should_be_called()
               :and_will_return(3)
               :and_also(
                 mapScoreMockB.getRank
                              :should_be_called()
                              :and_will_return(1)
               )
               :and_also(
                 mapScoreMockC.getRank
                              :should_be_called()
                              :and_will_return(2)
               )
               :when(
                 function()
                   mapScoreList:refreshRankScoreCache()
                 end
               )

  mapScoreMockA.getMilliseconds
               :may_be_called()
               :multiple_times(13)
               :and_will_return(20000)
               :and_also(
                 mapScoreMockB.getMilliseconds
                              :may_be_called()
                              :multiple_times(13)
                              :and_will_return(12345)
               )
               :and_also(
                 mapScoreMockC.getMilliseconds
                              :may_be_called()
                              :multiple_times(13)
                              :and_will_return(14879)
               )
               :when(
                 function()
                   self:assertEquals(0, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(3000))
                   self:assertEquals(0, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(12344))
                   self:assertEquals(1, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(12345))
                   self:assertEquals(1, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(12346))
                   self:assertEquals(1, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(13516))
                   self:assertEquals(1, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(14878))
                   self:assertEquals(2, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(14879))
                   self:assertEquals(2, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(14880))
                   self:assertEquals(2, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(16321))
                   self:assertEquals(2, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(19999))
                   self:assertEquals(3, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(20000))
                   self:assertEquals(3, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(20001))
                   self:assertEquals(3, mapScoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(24000))
                 end
               )

end


-- Protected Methods

---
-- Creates and returns a ScoreList instance.
--
-- @tparam bool _mergeScoresByPlayerName The mergeScoresByPlayerName setting to create the ScoreList with
--
-- @treturn MapScoreList The created ScoreList instance
--
function TestMapScoreList:createScoreListInstance(_mergeScoresByPlayerName)
  local MapScoreList = self.testClass
  return MapScoreList(_mergeScoresByPlayerName)
end

---
-- Creates and returns a Score mock.
--
-- @treturn MapScore The created Score mock
--
function TestMapScoreList:createScoreMock()

  local mapScoreMock = self:getMock("GemaScoreManager.MapScore.MapScore")
  mapScoreMock.getPlayer = self.mach.mock_method("getPlayerMock")
  mapScoreMock.getRank = self.mach.mock_method("getRankMock")

  return mapScoreMock

end


return TestMapScoreList
