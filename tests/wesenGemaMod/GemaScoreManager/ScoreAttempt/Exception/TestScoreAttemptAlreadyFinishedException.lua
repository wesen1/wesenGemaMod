---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the ScoreAttemptAlreadyFinishedException works as expected.
--
-- @type TestScoreAttemptAlreadyFinishedException
--
local TestScoreAttemptAlreadyFinishedException = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestScoreAttemptAlreadyFinishedException.testClassPath = "GemaScoreManager.ScoreAttempt.Exception.ScoreAttemptAlreadyFinishedException"


---
-- Checks that the ScoreAttemptAlreadyFinishedException can be instantiated as expected.
--
function TestScoreAttemptAlreadyFinishedException:testCanBeCreated()

  local ScoreAttemptAlreadyFinishedException = self.testClass
  local exception = ScoreAttemptAlreadyFinishedException("startTimestamp")

  self:assertEquals("startTimestamp", exception:getModifiedAttributeName())

  self:assertEquals(
    "Could not modify ScoreAttempt attribute \"startTimestamp\": ScoreAttempt is already finished",
    exception:getMessage()
  )

end


return TestScoreAttemptAlreadyFinishedException
