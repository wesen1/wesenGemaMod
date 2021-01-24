---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the ScoreAttemptNotFinishedException works as expected.
--
-- @type TestScoreAttemptNotFinishedException
--
local TestScoreAttemptNotFinishedException = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestScoreAttemptNotFinishedException.testClassPath = "GemaScoreManager.ScoreAttempt.Exception.ScoreAttemptNotFinishedException"


---
-- Checks that the ScoreAttemptNotFinishedException can be instantiated as expected.
--
function TestScoreAttemptNotFinishedException:testCanBeCreated()

  local ScoreAttemptNotFinishedException = self.testClass
  local exception = ScoreAttemptNotFinishedException("endTimestamp")

  self:assertEquals("endTimestamp", exception:getFetchedAttributeName())

  self:assertEquals(
    "Could not fetch attribute \"endTimestamp\" from ScoreAttempt: ScoreAttempt is not finished yet",
    exception:getMessage()
  )

end


return TestScoreAttemptNotFinishedException
