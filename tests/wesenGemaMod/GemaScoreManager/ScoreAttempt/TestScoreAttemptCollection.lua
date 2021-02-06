---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the ScoreAttemptCollection works as expected.
--
-- @type TestScoreAttemptCollection
--
local TestScoreAttemptCollection = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestScoreAttemptCollection.testClassPath = "GemaScoreManager.ScoreAttempt.ScoreAttemptCollection"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestScoreAttemptCollection.dependencyPaths = {
  { id = "LuaServerApi", path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" },
  { id = "ScoreAttempt", path = "GemaScoreManager.ScoreAttempt.ScoreAttempt" }
}

---
-- Event listener for the "scoreAttemptStarted" event of the ScoreAttemptCollection
--
-- @tfield function onScoreAttemptStartedListener
--
TestScoreAttemptCollection.onScoreAttemptStartedListener = nil

---
-- Event listener for the "scoreAttemptFinished" event of the ScoreAttemptCollection
--
-- @tfield function onScoreAttemptFinishedListener
--
TestScoreAttemptCollection.onScoreAttemptFinishedListener = nil

---
-- Event listener for the "scoreAttemptCancelled" event of the ScoreAttemptCollection
--
-- @tfield function onScoreAttemptCancelledListener
--
TestScoreAttemptCollection.onScoreAttemptCancelledListener = nil


---
-- Method that is called before a test is executed.
-- Creates the event listeners and initializes the LuaServerApiMock
--
function TestScoreAttemptCollection:setUp()

  TestCase.setUp(self)

  self.onScoreAttemptStartedListener = self.mach.mock_function("onScoreAttemptStartedListener")
  self.onScoreAttemptFinishedListener = self.mach.mock_function("onScoreAttemptFinishedListener")
  self.onScoreAttemptCancelledListener = self.mach.mock_function("onScoreAttemptCancelledListener")

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.getsvtick = self.mach.mock_function("getsvtickMock")
  LuaServerApiMock.getteam = self.mach.mock_function("getteam")

  -- Define all relevant team IDs
  LuaServerApiMock.TEAM_CLA = 0
  LuaServerApiMock.TEAM_RVSF = 1

  -- Define all relevant weapon IDs
  LuaServerApiMock.GUN_KNIFE = 0
  LuaServerApiMock.GUN_GRENADE = 8
  LuaServerApiMock.GUN_PISTOL = 1
  LuaServerApiMock.GUN_AKIMBO = 9

  LuaServerApiMock.GUN_ASSAULT = 6
  LuaServerApiMock.GUN_SUBGUN = 4
  LuaServerApiMock.GUN_CARBINE = 2
  LuaServerApiMock.GUN_SNIPER = 5
  LuaServerApiMock.GUN_SHOTGUN = 3

end

---
-- Method that is called after a test was executed.
-- Clears the event listeners.
--
function TestScoreAttemptCollection:tearDown()
  TestCase.tearDown(self)

  self.onScoreAttemptStartedListener = nil
  self.onScoreAttemptFinishedListener = nil
  self.onScoreAttemptCancelledListener = nil
end


---
-- Checks that a ScoreAttempt for a player can be started as expected.
--
function TestScoreAttemptCollection:testCanStartScoreAttempt()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local ScoreAttemptMock = self.dependencyMocks.ScoreAttempt

  local scoreAttemptCollection = self:createScoreAttemptCollection()
  local scoreAttemptMock = self:getMock("GemaScoreManager.ScoreAttempt.ScoreAttempt")

  LuaServerApiMock.getsvtick
                  :should_be_called()
                  :and_will_return(512133)
                  :and_also(
                    LuaServerApiMock.getteam
                                    :should_be_called_with(7)
                                    :and_will_return(LuaServerApiMock.TEAM_CLA)
                  )
                  :and_then(
                    ScoreAttemptMock.__call
                                    :should_be_called_with(512133, LuaServerApiMock.TEAM_CLA)
                                    :and_will_return(scoreAttemptMock)
                  )
                  :and_then(
                    self.onScoreAttemptStartedListener:should_be_called_with(7, scoreAttemptMock)
                  )
                  :when(
                    function()
                      scoreAttemptCollection:startScoreAttempt(7)
                    end
                  )

end

---
-- Checks that a ScoreAttempt for a player can be cancelled as expected.
--
function TestScoreAttemptCollection:testCanCancelScoreAttempt()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi

  local scoreAttemptCollection = self:createScoreAttemptCollection()
  local scoreAttemptMock = self:getMock("GemaScoreManager.ScoreAttempt.ScoreAttempt")

  self:expectScoreAttemptStart(3, 987654, LuaServerApiMock.TEAM_CLA, scoreAttemptMock)
      :and_then(
        self.onScoreAttemptCancelledListener
            :should_be_called_with(3, scoreAttemptMock, "Player died")
      )
      :when(
        function()
          scoreAttemptCollection:startScoreAttempt(3)
          scoreAttemptCollection:cancelScoreAttempt(3, "Player died")

          -- Another ScoreAttempt cancel for the same player should be ignored
          scoreAttemptCollection:cancelScoreAttempt(3)

          -- A ScoreAttempt cancel for a player without active ScoreAttempt should be ignored too
          scoreAttemptCollection:cancelScoreAttempt(9)

          self:verifyThatNoScoreAttemptForPlayerExists(scoreAttemptCollection, 3)
        end
      )

end

---
-- Checks that the current active ScoreAttempt for a player is cancelled when a new ScoreAttempt
-- is started before the old ScoreAttempt was cancelled.
--
function TestScoreAttemptCollection:testCancelsCurrentScoreAttemptIfOldScoreAttemptExistsOnScoreAttemptStart()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi

  local scoreAttemptCollection = self:createScoreAttemptCollection()
  local scoreAttemptMockA = self:getMock("GemaScoreManager.ScoreAttempt.ScoreAttempt")
  local scoreAttemptMockB = self:getMock("GemaScoreManager.ScoreAttempt.ScoreAttempt")

  self:expectScoreAttemptStart(8, 456123, LuaServerApiMock.TEAM_RVSF, scoreAttemptMockA)
      :and_then(
        self.onScoreAttemptCancelledListener
            :should_be_called_with(8, scoreAttemptMockA, "Next ScoreAttempt started")
      )
      :and_then(
        self:expectScoreAttemptStart(8, 460000, LuaServerApiMock.TEAM_RVSF, scoreAttemptMockB)
      )
      :when(
        function()
          scoreAttemptCollection:startScoreAttempt(8)
          scoreAttemptCollection:startScoreAttempt(8)
        end
      )

end

---
-- Checks that the ScoreAttempt's of all players can be cancelled at once.
--
function TestScoreAttemptCollection:testCanCancelAllScoreAttempts()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi

  local scoreAttemptCollection = self:createScoreAttemptCollection()
  local scoreAttemptMockA = self:getMock("GemaScoreManager.ScoreAttempt.ScoreAttempt")
  local scoreAttemptMockB = self:getMock("GemaScoreManager.ScoreAttempt.ScoreAttempt")
  local scoreAttemptMockC = self:getMock("GemaScoreManager.ScoreAttempt.ScoreAttempt")
  local scoreAttemptMockD = self:getMock("GemaScoreManager.ScoreAttempt.ScoreAttempt")
  local scoreAttemptMockE = self:getMock("GemaScoreManager.ScoreAttempt.ScoreAttempt")

  self:expectScoreAttemptStart(1, 123123, LuaServerApiMock.TEAM_CLA, scoreAttemptMockA)
      :and_then(
        self:expectScoreAttemptStart(2, 213213, LuaServerApiMock.TEAM_CLA, scoreAttemptMockB)
      )
      :and_then(
        self:expectScoreAttemptStart(3, 321321, LuaServerApiMock.TEAM_CLA, scoreAttemptMockC)
      )
      :and_then(
        self:expectScoreAttemptStart(4, 312321, LuaServerApiMock.TEAM_CLA, scoreAttemptMockD)
      )
      :and_then(
        self:expectScoreAttemptStart(5, 111111, LuaServerApiMock.TEAM_CLA, scoreAttemptMockE)
      )
      :and_then(
        self.onScoreAttemptCancelledListener
            :should_be_called_with(1, scoreAttemptMockA, "Game ended")
      )
      :and_then(
        self.onScoreAttemptCancelledListener
            :should_be_called_with(2, scoreAttemptMockB, "Game ended")
      )
      :and_then(
        self.onScoreAttemptCancelledListener
            :should_be_called_with(3, scoreAttemptMockC, "Game ended")
      )
      :and_then(
        self.onScoreAttemptCancelledListener
            :should_be_called_with(4, scoreAttemptMockD, "Game ended")
      )
      :and_then(
        self.onScoreAttemptCancelledListener
            :should_be_called_with(5, scoreAttemptMockE, "Game ended")
      )
      :when(
        function()
          scoreAttemptCollection:startScoreAttempt(1)
          scoreAttemptCollection:startScoreAttempt(2)
          scoreAttemptCollection:startScoreAttempt(3)
          scoreAttemptCollection:startScoreAttempt(4)
          scoreAttemptCollection:startScoreAttempt(5)

          scoreAttemptCollection:cancelAllScoreAttempts("Game ended")

          self:verifyThatNoScoreAttemptForPlayerExists(scoreAttemptCollection, 1)
          self:verifyThatNoScoreAttemptForPlayerExists(scoreAttemptCollection, 2)
          self:verifyThatNoScoreAttemptForPlayerExists(scoreAttemptCollection, 3)
          self:verifyThatNoScoreAttemptForPlayerExists(scoreAttemptCollection, 4)
          self:verifyThatNoScoreAttemptForPlayerExists(scoreAttemptCollection, 5)
        end
      )

end

---
-- Checks that the ScoreAttemptCollection can be cleared as expected.
--
function TestScoreAttemptCollection:testCanBeCleared()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi

  local scoreAttemptCollection = self:createScoreAttemptCollection()
  local scoreAttemptMockA = self:getMock("GemaScoreManager.ScoreAttempt.ScoreAttempt")
  local scoreAttemptMockB = self:getMock("GemaScoreManager.ScoreAttempt.ScoreAttempt")
  local scoreAttemptMockC = self:getMock("GemaScoreManager.ScoreAttempt.ScoreAttempt")
  local scoreAttemptMockD = self:getMock("GemaScoreManager.ScoreAttempt.ScoreAttempt")
  local scoreAttemptMockE = self:getMock("GemaScoreManager.ScoreAttempt.ScoreAttempt")

  self:expectScoreAttemptStart(1, 123123, LuaServerApiMock.TEAM_CLA, scoreAttemptMockA)
      :and_then(
        self:expectScoreAttemptStart(2, 213213, LuaServerApiMock.TEAM_CLA, scoreAttemptMockB)
      )
      :and_then(
        self:expectScoreAttemptStart(3, 321321, LuaServerApiMock.TEAM_CLA, scoreAttemptMockC)
      )
      :and_then(
        self:expectScoreAttemptStart(4, 312321, LuaServerApiMock.TEAM_CLA, scoreAttemptMockD)
      )
      :and_then(
        self:expectScoreAttemptStart(5, 111111, LuaServerApiMock.TEAM_CLA, scoreAttemptMockE)
      )
      :when(
        function()
          scoreAttemptCollection:startScoreAttempt(1)
          scoreAttemptCollection:startScoreAttempt(2)
          scoreAttemptCollection:startScoreAttempt(3)
          scoreAttemptCollection:startScoreAttempt(4)
          scoreAttemptCollection:startScoreAttempt(5)

          scoreAttemptCollection:clear()

          self:verifyThatNoScoreAttemptForPlayerExists(scoreAttemptCollection, 1)
          self:verifyThatNoScoreAttemptForPlayerExists(scoreAttemptCollection, 2)
          self:verifyThatNoScoreAttemptForPlayerExists(scoreAttemptCollection, 3)
          self:verifyThatNoScoreAttemptForPlayerExists(scoreAttemptCollection, 4)
          self:verifyThatNoScoreAttemptForPlayerExists(scoreAttemptCollection, 5)
        end
      )

end

---
-- Checks that a ScoreAttempt's weapon can be updated as expected.
--
function TestScoreAttemptCollection:testCanUpdateScoreAttemptWeapon()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi

  local scoreAttemptCollection = self:createScoreAttemptCollection()
  local scoreAttemptMock = self:getMock("GemaScoreManager.ScoreAttempt.ScoreAttempt")

  self:expectScoreAttemptStart(13, 491231, LuaServerApiMock.TEAM_RVSF, scoreAttemptMock)
      :and_then(
        scoreAttemptMock.updateWeaponIfRequired
                        :should_be_called_with(LuaServerApiMock.GUN_ASSAULT)
      )
      :when(
        function()
          scoreAttemptCollection:startScoreAttempt(13)
          scoreAttemptCollection:updateScoreAttemptWeaponIfRequired(13, LuaServerApiMock.GUN_ASSAULT)

          -- Nothing should happen for a player without active ScoreAttempt
          scoreAttemptCollection:updateScoreAttemptWeaponIfRequired(4, LuaServerApiMock.GUN_SUBGUN)
        end
      )

end

---
-- Checks that a flag score of a player is processed as expected.
--
function TestScoreAttemptCollection:testCanProcessFlagScoreForPlayer()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi

  local scoreAttemptCollection = self:createScoreAttemptCollection()
  local scoreAttemptMock = self:getMock("GemaScoreManager.ScoreAttempt.ScoreAttempt")

  self:expectScoreAttemptStart(15, 123456, LuaServerApiMock.TEAM_RVSF, scoreAttemptMock)
      :and_then(
        LuaServerApiMock.getsvtick
                        :should_be_called()
                        :and_will_return(456789)
                        :and_then(
                          scoreAttemptMock.finish
                                          :should_be_called_with(456789)
                        )
      )
      :and_then(
        self.onScoreAttemptFinishedListener
            :should_be_called_with(15, scoreAttemptMock)
      )
      :when(
        function()
          scoreAttemptCollection:startScoreAttempt(15)
          scoreAttemptCollection:processFlagScore(15)

          -- Flag score of the player who just finished his ScoreAttempt should be ignored
          scoreAttemptCollection:processFlagScore(15)

          -- Flag score of a player with no active ScoreAttempt should be ignored too
          scoreAttemptCollection:processFlagScore(1)

          self:verifyThatNoScoreAttemptForPlayerExists(scoreAttemptCollection, 15)
        end
      )

end


-- Private Methods

---
-- Creates and returns a ScoreAttemptCollection instance.
-- Also attaches the event listeners to the ScoreAttemptCollection instance.
--
-- @treturn ScoreAttemptCollection The created ScoreAttemptCollection instance
--
function TestScoreAttemptCollection:createScoreAttemptCollection()

  local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
  local ScoreAttemptCollection = self.testClass

  local scoreAttemptCollection = ScoreAttemptCollection()

  scoreAttemptCollection:on("scoreAttemptStarted", EventCallback(function(...)
    self.onScoreAttemptStartedListener(...)
  end))
  scoreAttemptCollection:on("scoreAttemptFinished", EventCallback(function(...)
    self.onScoreAttemptFinishedListener(...)
  end))
  scoreAttemptCollection:on("scoreAttemptCancelled", EventCallback(function(...)
    self.onScoreAttemptCancelledListener(...)
  end))

  return scoreAttemptCollection

end

---
-- Sets up and returns the required expectations for a ScoreAttempt start.
--
-- @tparam int _cn The client number of the player whose ScoreAttempt is expected to be started
-- @tparam int _startTimestamp The start timestamp for the ScoreAttempt
-- @tparam int _teamId The team of the player
-- @tparam ScoreAttempt _scoreAttemptMock The ScoreAttemptMock to return by the ScoreAttempt constructor
--
-- @treturn table The mock expectations for the expected ScoreAttempt start
--
function TestScoreAttemptCollection:expectScoreAttemptStart(_cn, _startTimestamp, _teamId, _scoreAttemptMock)

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local ScoreAttemptMock = self.dependencyMocks.ScoreAttempt

  return LuaServerApiMock.getsvtick
                         :should_be_called()
                         :and_will_return(_startTimestamp)
                         :and_also(
                           LuaServerApiMock.getteam
                                           :should_be_called_with(_cn)
                                           :and_will_return(_teamId)
                         )
                         :and_then(
                           ScoreAttemptMock.__call
                                           :should_be_called_with(_startTimestamp, _teamId)
                                           :and_will_return(_scoreAttemptMock)
                         )
                         :and_then(
                           self.onScoreAttemptStartedListener
                               :should_be_called_with(_cn, _scoreAttemptMock)
                         )

end

---
-- Verifies that no active ScoreAttempt for a given player exists in a ScoreAttemptCollection.
-- This is done by calling ScoreAttempt updating methods on the ScoreAttemptCollection which
-- would trigger event listeners or mock method calls if there was an active ScoreAttempt for the
-- player.
--
-- @tparam ScoreAttemptCollection _scoreAttemptCollection The ScoreAttemptCollection to check
-- @tparam int _cn The client number of the player for which to verify that no active ScoreAttempt exists
--
function TestScoreAttemptCollection:verifyThatNoScoreAttemptForPlayerExists(_scoreAttemptCollection, _cn)

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi

  _scoreAttemptCollection:updateScoreAttemptWeaponIfRequired(_cn, LuaServerApiMock.GUN_SNIPER)
  _scoreAttemptCollection:processFlagScore(_cn)
  _scoreAttemptCollection:cancelScoreAttempt(_cn, "Checking if this will do something")

end


return TestScoreAttemptCollection
