---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the PlayerNameNotUniqueException works as expected.
--
-- @type TestPlayerNameNotUniqueException
--
local TestPlayerNameNotUniqueException = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestPlayerNameNotUniqueException.testClassPath = "GemaScoreManager.Score.Exception.PlayerNameNotUniqueException"


---
-- Checks that the PlayerNameNotUniqueException can be instantiated as expected.
--
function TestPlayerNameNotUniqueException:testCanBeCreated()

  local PlayerNameNotUniqueException = self.testClass

  local playerMockA = {}
  local playerMockB = {}
  local playerMockC = {}

  local exception = PlayerNameNotUniqueException("MapScore", "unarmedpro", { playerMockA, playerMockB, playerMockC })

  self:assertEquals("MapScore", exception:getFetchedInformationName())
  self:assertEquals("unarmedpro", exception:getPlayerName())
  self:assertEquals({ playerMockA, playerMockB, playerMockC }, exception:getMatchingPlayers())

  self:assertEquals(
    "Could not fetch MapScore by player name \"unarmedpro\": Multiple Player's found with that name",
    exception:getMessage()
  )

end


return TestPlayerNameNotUniqueException
