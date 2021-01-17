---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Base class for Score class tests.
--
-- @type ScoreTestBase
--
local ScoreTestBase = TestCase:extend()


---
-- Checks that a Score can be created without an initial rank.
--
function ScoreTestBase:testCanBeCreatedWithoutInitialRank()

  local playerMock = self:createPlayerMock()
  local score = self:createScoreInstance(playerMock, nil)

  self:assertIs(playerMock, score:getPlayer())
  self:assertEquals(nil, score:getRank())

end

---
-- Checks that a Score can be created with an initial rank.
--
function ScoreTestBase:testCanBeCreatedWithInitialRank()

  local playerMock = self:createPlayerMock()
  local score = self:createScoreInstance(playerMock, 5)

  self:assertIs(playerMock, score:getPlayer())
  self:assertEquals(5, score:getRank())

end

---
-- Checks that a Score's rank can be changed as expected.
--
function ScoreTestBase:testCanChangeRank()

  -- Without initial rank
  local playerMockA = self:createPlayerMock()
  local scoreWithoutInitialRank = self:createScoreInstance(playerMockA, nil)
  self:assertNil(scoreWithoutInitialRank:getRank())

  scoreWithoutInitialRank:setRank(6)
  self:assertEquals(6, scoreWithoutInitialRank:getRank())

  scoreWithoutInitialRank:setRank(3)
  self:assertEquals(3, scoreWithoutInitialRank:getRank())

  scoreWithoutInitialRank:setRank(4)
  self:assertEquals(4, scoreWithoutInitialRank:getRank())


  -- With initial rank
  local playerMockB = self:createPlayerMock()
  local scoreWithInitialRank = self:createScoreInstance(playerMockB, 18)
  self:assertEquals(18, scoreWithInitialRank:getRank())

  scoreWithInitialRank:setRank(11)
  self:assertEquals(11, scoreWithInitialRank:getRank())

  scoreWithInitialRank:setRank(12)
  self:assertEquals(12, scoreWithInitialRank:getRank())

  scoreWithInitialRank:setRank(19)
  self:assertEquals(19, scoreWithInitialRank:getRank())

end


-- Protected Methods

---
-- Creates and returns a Score instance.
--
-- @tparam Player _player The Player to create the Score instance with
-- @tparam int _rank The initial rank of the Score instance
--
-- @treturn Score The created Score instance
--
function ScoreTestBase:createScoreInstance(_player, _rank)
end

---
-- Creates and returns a Player mock.
--
-- @treturn Player The created Player mock
--
function ScoreTestBase:createPlayerMock()
  return {
    getIp = self.mach.mock_method("getIpMock"),
    getName = self.mach.mock_method("getNameMock")
  }
end


return ScoreTestBase
