---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Base class for ScoreListManager class tests.
--
-- @type ScoreListManagerTestBase
--
local ScoreListManagerTestBase = TestCase:extend()


---
-- Checks that the ScoreListManager can be created as expected.
--
function ScoreListManagerTestBase:testCanBeCreated()
  local scoreListMock = self:createScoreListMock()
  local scoreListManager = self:createScoreListManagerInstance(scoreListMock)

  self:assertIs(scoreListMock, scoreListManager:getScoreList())
end


-- Protected Methods

---
-- Creates and returns a ScoreListManager instance.
--
-- @tparam ScoreList The ScoreList to create the ScoreListManager instance with
--
-- @treturn ScoreListManager The created ScoreListManager instance
--
function ScoreListManagerTestBase:createScoreListManagerInstance(_scoreList)
end

---
-- Creates and returns a ScoreList mock.
--
-- @treturn ScoreList The created ScoreList mock
--
function ScoreListManagerTestBase:createScoreListMock()
end


return ScoreListManagerTestBase
