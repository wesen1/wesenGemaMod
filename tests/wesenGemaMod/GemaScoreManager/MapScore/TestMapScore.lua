---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ScoreTestBase = require "wesenGemaMod.GemaScoreManager.Score.ScoreTestBase"

---
-- Checks that the MapScore works as expected.
--
-- @type TestMapScore
--
local TestMapScore = ScoreTestBase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestMapScore.testClassPath = "GemaScoreManager.MapScore.MapScore"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestMapScore.dependencyPaths = {
  { id = "os", path = "os", ["type"] = "globalVariable" }
}

---
-- Checks that a MapScore can be instantiated with only the mandatory values set.
--
function TestMapScore:testCanBeCreatedWithOnlyMandatoryValues()

  local osMock = self.dependencyMocks.os
  osMock.time = self.mach.mock_function("os.time mock")

  local MapScore = self.testClass

  local playerMock = self:createPlayerMock()
  local mapScore
  osMock.time
        :should_be_called()
        :and_will_return(1610148606)
        :when(
          function()
            mapScore = MapScore(playerMock, 12345, 6, 1)
          end
        )

  self:assertEquals(playerMock, mapScore:getPlayer())
  self:assertEquals(12345, mapScore:getMilliseconds())
  self:assertEquals(6, mapScore:getWeaponId())
  self:assertEquals(1, mapScore:getTeamId())
  self:assertEquals(1610148606, mapScore:getCreatedAt())
  self:assertNil(mapScore:getRank())

end

---
-- Checks that a MapScore can be instantiated with all values set.
--
function TestMapScore:testCanBeCreatedWithAllValues()

  local MapScore = self.testClass

  local playerMock = self:createPlayerMock()
  local mapScore = MapScore(playerMock, 23412, 3, 0, 1570525205, 2)

  self:assertEquals(playerMock, mapScore:getPlayer())
  self:assertEquals(23412, mapScore:getMilliseconds())
  self:assertEquals(3, mapScore:getWeaponId())
  self:assertEquals(0, mapScore:getTeamId())
  self:assertEquals(1570525205, mapScore:getCreatedAt())
  self:assertEquals(2, mapScore:getRank())

end

---
-- Checks that a MapScore can cache a generated formatted time string as expected.
--
function TestMapScore:testCanCachedGeneratedTimeString()

  local MapScore = self.testClass

  local playerMock = self:createPlayerMock()
  local mapScore = MapScore(playerMock, 98765, 5, 1, 1604422804, 2)

  self:assertNil(mapScore:getTimeString())

  mapScore:setTimeString("1m 38s 765ms")
  self:assertEquals("1m 38s 765ms", mapScore:getTimeString())

  mapScore:setTimeString("01:38,765 minutes")
  self:assertEquals("01:38,765 minutes", mapScore:getTimeString())

  mapScore:setTimeString("1min 38.765sec")
  self:assertEquals("1min 38.765sec", mapScore:getTimeString())

end


-- Protected Methods

---
-- Creates and returns a Score instance.
--
-- @tparam Player _player The Player to create the Score instance with
-- @tparam int _rank The initial rank of the Score instance
--
-- @treturn MapScore The created Score instance
--
function TestMapScore:createScoreInstance(_player, _initialRank)
  local MapScore = self.testClass
  return MapScore(_player, 98765, 5, 1, 1604422804, _initialRank)
end


return TestMapScore
