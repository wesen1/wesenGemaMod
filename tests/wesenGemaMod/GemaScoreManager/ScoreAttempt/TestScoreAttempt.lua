---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the ScoreAttempt works as expected.
--
-- @type TestScoreAttempt
--
local TestScoreAttempt = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestScoreAttempt.testClassPath = "GemaScoreManager.ScoreAttempt.ScoreAttempt"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestScoreAttempt.dependencyPaths = {
  { id = "LuaServerApi", path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" }
}


---
-- Method that is called before a test is executed.
--
function TestScoreAttempt:setUp()
  TestCase.setUp(self)

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi

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

  -- Define all relevant team IDs
  LuaServerApiMock.TEAM_CLA = 0
  LuaServerApiMock.TEAM_RVSF = 1

end


---
-- Checks that a ScoreAttempt can be finished without stealing the flag from its original position.
--
function TestScoreAttempt:testCanBeFinishedWithoutStealingTheFlagFromOriginalPosition()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local ScoreAttempt = self.testClass

  local scoreAttempt = ScoreAttempt(13214, LuaServerApiMock.TEAM_RVSF)
  self:assertFalse(scoreAttempt:isFinished())
  self:assertFalse(scoreAttempt:getDidStealFlag())

  scoreAttempt:finish(49401)
  self:assertTrue(scoreAttempt:isFinished())
  self:assertFalse(scoreAttempt:getDidStealFlag())

end

---
-- Checks that a ScoreAttempt can be finished with stealing the flag from its original position.
--
function TestScoreAttempt:testCanBeFinishedWithStealingTheFlag()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local ScoreAttempt = self.testClass

  local scoreAttempt = ScoreAttempt(13214, LuaServerApiMock.TEAM_RVSF)
  self:assertFalse(scoreAttempt:isFinished())
  self:assertFalse(scoreAttempt:getDidStealFlag())

  scoreAttempt:markFlagStolen()
  self:assertTrue(scoreAttempt:getDidStealFlag())

  scoreAttempt:finish(49401)
  self:assertTrue(scoreAttempt:isFinished())
  self:assertTrue(scoreAttempt:getDidStealFlag())

end

---
-- Checks that the ScoreAttempt keeps track of the ID of the team to which the Player belongs during the attempt.
--
function TestScoreAttempt:testKeepsTrackOfTeamId()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local ScoreAttempt = self.testClass

  -- CLA
  local claScoreAttempt = ScoreAttempt(126356, LuaServerApiMock.TEAM_CLA)
  self:assertEquals(LuaServerApiMock.TEAM_CLA, claScoreAttempt:getTeamId())

  claScoreAttempt:markFlagStolen()
  self:assertEquals(LuaServerApiMock.TEAM_CLA, claScoreAttempt:getTeamId())

  claScoreAttempt:finish(136900)
  self:assertEquals(LuaServerApiMock.TEAM_CLA, claScoreAttempt:getTeamId())


  -- RVSF
  local rvsfScoreAttempt = ScoreAttempt(512316, LuaServerApiMock.TEAM_RVSF)
  self:assertEquals(LuaServerApiMock.TEAM_RVSF, rvsfScoreAttempt:getTeamId())

  rvsfScoreAttempt:markFlagStolen()
  self:assertEquals(LuaServerApiMock.TEAM_RVSF, rvsfScoreAttempt:getTeamId())

  rvsfScoreAttempt:finish(617003)
  self:assertEquals(LuaServerApiMock.TEAM_RVSF, rvsfScoreAttempt:getTeamId())

end

---
-- Checks that the ScoreAttempt can calculate the time that the player took to score.
--
function TestScoreAttempt:testCanCalculateDuration()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local ScoreAttempt = self.testClass

  -- Score attempt that steals the flag from the original position
  local scoreAttemptA = ScoreAttempt(13214, LuaServerApiMock.TEAM_RVSF)
  scoreAttemptA:markFlagStolen()
  scoreAttemptA:finish(49401)
  self:assertTrue(scoreAttemptA:isFinished())
  self:assertEquals(36187, scoreAttemptA:getDuration())

  -- Score attempt that does not steal the flag from the original position
  local scoreAttemptB = ScoreAttempt(512316, LuaServerApiMock.TEAM_RVSF)
  scoreAttemptB:markFlagStolen()
  scoreAttemptB:finish(617003)
  self:assertTrue(scoreAttemptB:isFinished())
  self:assertEquals(104687, scoreAttemptB:getDuration())

end


---
-- Checks that the ScoreAttempt weapon is updated to PISTOL if PISTOL is used.
--
function TestScoreAttempt:testUpdatesScoreWeaponToPistolIfPistolIsUsed()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local ScoreAttempt = self.testClass

  local scoreAttempt = ScoreAttempt(13214, LuaServerApiMock.TEAM_CLA)
  self:assertEquals(LuaServerApiMock.GUN_KNIFE, scoreAttempt:getWeaponId()) -- Should be KNIFE initially

  scoreAttempt:updateWeaponIfRequired(LuaServerApiMock.GUN_PISTOL) -- PISTOL was used
  self:assertEquals(LuaServerApiMock.GUN_PISTOL, scoreAttempt:getWeaponId()) -- Should now be PISTOL

end

---
-- Checks that the ScoreAttempt weapon is updated to PISTOL if AKIMBO is used.
--
function TestScoreAttempt:testUpdatesScoreWeaponToPistolIfAkimboIsUsed()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local ScoreAttempt = self.testClass

  local scoreAttempt = ScoreAttempt(13214, LuaServerApiMock.TEAM_RVSF)
  self:assertEquals(LuaServerApiMock.GUN_KNIFE, scoreAttempt:getWeaponId()) -- Should be KNIFE initially

  scoreAttempt:updateWeaponIfRequired(LuaServerApiMock.GUN_AKIMBO) -- AKIMBO was used
  self:assertEquals(LuaServerApiMock.GUN_PISTOL, scoreAttempt:getWeaponId()) -- Should now be PISTOL

end

---
-- Checks that the ScoreAttempt weapon is updated to <primary weapon> if <primary weapon> is used.
--
function TestScoreAttempt:testUpdatesScoreWeaponToPrimaryIfPrimaryIsUsed()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi

  self:updatesScoreWeaponToPrimaryIfPrimaryIsUsed(LuaServerApiMock.GUN_ASSAULT)
  self:updatesScoreWeaponToPrimaryIfPrimaryIsUsed(LuaServerApiMock.GUN_SUBGUN)
  self:updatesScoreWeaponToPrimaryIfPrimaryIsUsed(LuaServerApiMock.GUN_CARBINE)
  self:updatesScoreWeaponToPrimaryIfPrimaryIsUsed(LuaServerApiMock.GUN_SNIPER)
  self:updatesScoreWeaponToPrimaryIfPrimaryIsUsed(LuaServerApiMock.GUN_SHOTGUN)

end

---
-- Checks that the ScoreAttempt weapon is updated to a given <primary weapon> if <primary weapon> is used.
--
-- @tparam int _primaryWeaponId The ID of the primary weapon to check
--
function TestScoreAttempt:updatesScoreWeaponToPrimaryIfPrimaryIsUsed(_primaryWeaponId)

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local ScoreAttempt = self.testClass

  local scoreAttempt = ScoreAttempt(13214, LuaServerApiMock.TEAM_CLA)
  self:assertEquals(LuaServerApiMock.GUN_KNIFE, scoreAttempt:getWeaponId()) -- Should be KNIFE initially

  scoreAttempt:updateWeaponIfRequired(_primaryWeaponId) -- <primary weapon> was used
  self:assertEquals(_primaryWeaponId, scoreAttempt:getWeaponId()) -- Should now be <primary weapon>

end


---
-- Checks that the ScoreAttempt weapon is updated to <primary weapon> if <primary weapon> is used after
-- using PISTOL.
--
function TestScoreAttempt:testUpdatesScoreWeaponToPrimaryIfPrimaryIsUsedAfterPistolUsage()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi

  self:updatesScoreWeaponToPrimaryIfPrimaryIsUsedAfterPistolUsage(LuaServerApiMock.GUN_ASSAULT)
  self:updatesScoreWeaponToPrimaryIfPrimaryIsUsedAfterPistolUsage(LuaServerApiMock.GUN_SUBGUN)
  self:updatesScoreWeaponToPrimaryIfPrimaryIsUsedAfterPistolUsage(LuaServerApiMock.GUN_CARBINE)
  self:updatesScoreWeaponToPrimaryIfPrimaryIsUsedAfterPistolUsage(LuaServerApiMock.GUN_SNIPER)
  self:updatesScoreWeaponToPrimaryIfPrimaryIsUsedAfterPistolUsage(LuaServerApiMock.GUN_SHOTGUN)

end

---
-- Checks that the ScoreAttempt weapon is updated to a given <primary weapon> if <primary weapon> is used
-- after using PISTOL.
--
-- @tparam int _primaryWeaponId The ID of the primary weapon to check
--
function TestScoreAttempt:updatesScoreWeaponToPrimaryIfPrimaryIsUsedAfterPistolUsage(_primaryWeaponId)

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local ScoreAttempt = self.testClass

  local scoreAttempt = ScoreAttempt(13214, LuaServerApiMock.TEAM_RVSF)
  self:assertEquals(LuaServerApiMock.GUN_KNIFE, scoreAttempt:getWeaponId()) -- Should be KNIFE initially

  scoreAttempt:updateWeaponIfRequired(LuaServerApiMock.GUN_PISTOL) -- PISTOL was used
  self:assertEquals(LuaServerApiMock.GUN_PISTOL, scoreAttempt:getWeaponId()) -- Should now be PISTOL

  scoreAttempt:updateWeaponIfRequired(_primaryWeaponId) -- <primary weapon> was used
  self:assertEquals(_primaryWeaponId, scoreAttempt:getWeaponId()) -- Should now be <primary weapon>

end


---
-- Checks that the ScoreAttempt weapon is not updated when the same weapon as the current ScoreAttempt
-- weapon is used.
--
function TestScoreAttempt:testDoesNotUpdateScoreWeaponIfSameWeaponAsCurrentScoreAttemptWeaponIsUsed()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi

  self:doesNotUpdateScoreWeaponIfSameWeaponAsCurrentScoreAttemptWeaponIsUsed(LuaServerApiMock.GUN_ASSAULT)
  self:doesNotUpdateScoreWeaponIfSameWeaponAsCurrentScoreAttemptWeaponIsUsed(LuaServerApiMock.GUN_SUBGUN)
  self:doesNotUpdateScoreWeaponIfSameWeaponAsCurrentScoreAttemptWeaponIsUsed(LuaServerApiMock.GUN_CARBINE)
  self:doesNotUpdateScoreWeaponIfSameWeaponAsCurrentScoreAttemptWeaponIsUsed(LuaServerApiMock.GUN_SNIPER)
  self:doesNotUpdateScoreWeaponIfSameWeaponAsCurrentScoreAttemptWeaponIsUsed(LuaServerApiMock.GUN_SHOTGUN)

end

---
-- Checks that the ScoreAttempt weapon is not updated when the same weapon as the current ScoreAttempt
-- weapon is used.
--
-- @tparam int _primaryWeaponId The ID of the primary weapon to use during the test
--
function TestScoreAttempt:doesNotUpdateScoreWeaponIfSameWeaponAsCurrentScoreAttemptWeaponIsUsed(_primaryWeaponId)

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local ScoreAttempt = self.testClass

  local scoreAttempt = ScoreAttempt(13214, LuaServerApiMock.TEAM_RVSF)
  self:assertEquals(LuaServerApiMock.GUN_KNIFE, scoreAttempt:getWeaponId()) -- Should be KNIFE initially

  scoreAttempt:updateWeaponIfRequired(LuaServerApiMock.GUN_KNIFE) -- KNIFE was used
  self:assertEquals(LuaServerApiMock.GUN_KNIFE, scoreAttempt:getWeaponId()) -- Should still be KNIFE

  scoreAttempt:updateWeaponIfRequired(LuaServerApiMock.GUN_PISTOL) -- PISTOL was used
  self:assertEquals(LuaServerApiMock.GUN_PISTOL, scoreAttempt:getWeaponId()) -- Should now be PISTOL

  scoreAttempt:updateWeaponIfRequired(LuaServerApiMock.GUN_PISTOL) -- PISTOL was used again
  self:assertEquals(LuaServerApiMock.GUN_PISTOL, scoreAttempt:getWeaponId()) -- Should still be PISTOL

  scoreAttempt:updateWeaponIfRequired(_primaryWeaponId) -- <primary weapon> was used
  self:assertEquals(_primaryWeaponId, scoreAttempt:getWeaponId()) -- Should now be <primary weapon>

  scoreAttempt:updateWeaponIfRequired(_primaryWeaponId) -- <primary weapon> was used
  self:assertEquals(_primaryWeaponId, scoreAttempt:getWeaponId()) -- Should still be <primary weapon>

end


---
-- Checks that the ScoreAttempt weapon is not updated when a "worse" weapon than the current ScoreAttempt
-- weapon is used.
--
function TestScoreAttempt:testDoesNotUpdateScoreWeaponIfWorseWeaponThanCurrentScoreAttemptWeaponIsUsed()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi

  self:doesNotUpdateScoreWeaponIfWorseWeaponThanCurrentScoreAttemptWeaponIsUsed(LuaServerApiMock.GUN_ASSAULT)
  self:doesNotUpdateScoreWeaponIfWorseWeaponThanCurrentScoreAttemptWeaponIsUsed(LuaServerApiMock.GUN_SUBGUN)
  self:doesNotUpdateScoreWeaponIfWorseWeaponThanCurrentScoreAttemptWeaponIsUsed(LuaServerApiMock.GUN_CARBINE)
  self:doesNotUpdateScoreWeaponIfWorseWeaponThanCurrentScoreAttemptWeaponIsUsed(LuaServerApiMock.GUN_SNIPER)
  self:doesNotUpdateScoreWeaponIfWorseWeaponThanCurrentScoreAttemptWeaponIsUsed(LuaServerApiMock.GUN_SHOTGUN)

end

---
-- Checks that the ScoreAttempt weapon is not updated when a "worse" weapon than the current ScoreAttempt
-- weapon is used.
--
-- @tparam int _primaryWeaponId The ID of the primary weapon to use during the test
--
function TestScoreAttempt:doesNotUpdateScoreWeaponIfWorseWeaponThanCurrentScoreAttemptWeaponIsUsed(_primaryWeaponId)

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local ScoreAttempt = self.testClass

  local scoreAttempt = ScoreAttempt(13214, LuaServerApiMock.TEAM_CLA)
  self:assertEquals(LuaServerApiMock.GUN_KNIFE, scoreAttempt:getWeaponId()) -- Should be KNIFE initially

  scoreAttempt:updateWeaponIfRequired(LuaServerApiMock.GUN_PISTOL) -- PISTOL was used
  self:assertEquals(LuaServerApiMock.GUN_PISTOL, scoreAttempt:getWeaponId()) -- Should now be PISTOL

  scoreAttempt:updateWeaponIfRequired(LuaServerApiMock.GUN_KNIFE) -- KNIFE was used
  self:assertEquals(LuaServerApiMock.GUN_PISTOL, scoreAttempt:getWeaponId()) -- Should still be PISTOL

  scoreAttempt:updateWeaponIfRequired(_primaryWeaponId) -- <primary weapon> was used
  self:assertEquals(_primaryWeaponId, scoreAttempt:getWeaponId()) -- Should now be <primary weapon>

  scoreAttempt:updateWeaponIfRequired(LuaServerApiMock.GUN_PISTOL) -- PISTOL was used
  self:assertEquals(_primaryWeaponId, scoreAttempt:getWeaponId()) -- Should still be <primary weapon>

  scoreAttempt:updateWeaponIfRequired(LuaServerApiMock.GUN_KNIFE) -- KNIFE was used
  self:assertEquals(_primaryWeaponId, scoreAttempt:getWeaponId()) -- Should still be <primary weapon>

end


---
-- Checks that the ScoreAttempt weapon is not updated when GRENADE is used.
--
function TestScoreAttempt:testDoesNotUpdateScoreWeaponIfGrenadeIsUsed()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi

  self:doesNotUpdateScoreWeaponIfGrenadeIsUsed(LuaServerApiMock.GUN_ASSAULT)
  self:doesNotUpdateScoreWeaponIfGrenadeIsUsed(LuaServerApiMock.GUN_SUBGUN)
  self:doesNotUpdateScoreWeaponIfGrenadeIsUsed(LuaServerApiMock.GUN_CARBINE)
  self:doesNotUpdateScoreWeaponIfGrenadeIsUsed(LuaServerApiMock.GUN_SNIPER)
  self:doesNotUpdateScoreWeaponIfGrenadeIsUsed(LuaServerApiMock.GUN_SHOTGUN)

end

---
-- Checks that the ScoreAttempt weapon is not updated when GRENADE is used.
--
-- @tparam int _primaryWeaponId The ID of the primary weapon to use during the test
--
function TestScoreAttempt:doesNotUpdateScoreWeaponIfGrenadeIsUsed(_primaryWeaponId)

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local ScoreAttempt = self.testClass

  local scoreAttempt = ScoreAttempt(13214, LuaServerApiMock.TEAM_RVSF)
  self:assertEquals(LuaServerApiMock.GUN_KNIFE, scoreAttempt:getWeaponId()) -- Should be KNIFE initially

  scoreAttempt:updateWeaponIfRequired(LuaServerApiMock.GUN_GRENADE) -- GRENADE was used
  self:assertEquals(LuaServerApiMock.GUN_KNIFE, scoreAttempt:getWeaponId()) -- Should still be KNIFE

  scoreAttempt:updateWeaponIfRequired(LuaServerApiMock.GUN_PISTOL) -- PISTOL was used
  self:assertEquals(LuaServerApiMock.GUN_PISTOL, scoreAttempt:getWeaponId()) -- Should now be PISTOL

  scoreAttempt:updateWeaponIfRequired(LuaServerApiMock.GUN_GRENADE) -- GRENADE was used
  self:assertEquals(LuaServerApiMock.GUN_PISTOL, scoreAttempt:getWeaponId()) -- Should still be PISTOL

  scoreAttempt:updateWeaponIfRequired(_primaryWeaponId) -- <primary weapon> was used
  self:assertEquals(_primaryWeaponId, scoreAttempt:getWeaponId()) -- Should now be <primary weapon>

  scoreAttempt:updateWeaponIfRequired(LuaServerApiMock.GUN_GRENADE) -- GRENADE was used
  self:assertEquals(_primaryWeaponId, scoreAttempt:getWeaponId()) -- Should still be <primary weapon>

end


---
-- Checks that an Exception is thrown when the ScoreAttempt should be modified after it was finished.
--
function TestScoreAttempt:testThrowsExceptionWhenScoreAttemptShouldBeModifiedAfterItWasFinished()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  local ScoreAttempt = self.testClass

  local ScoreAttemptAlreadyFinishedException = require "GemaScoreManager.ScoreAttempt.Exception.ScoreAttemptAlreadyFinishedException"

  local scoreAttempt = ScoreAttempt(13214, LuaServerApiMock.TEAM_CLA)
  scoreAttempt:finish(49401)
  self:assertTrue(scoreAttempt:isFinished())

  self:throwsExceptionWhenWeaponUsageIsReportedAfterItWasFinished(scoreAttempt, LuaServerApiMock.GUN_KNIFE)
  self:throwsExceptionWhenWeaponUsageIsReportedAfterItWasFinished(scoreAttempt, LuaServerApiMock.GUN_PISTOL)
  self:throwsExceptionWhenWeaponUsageIsReportedAfterItWasFinished(scoreAttempt, LuaServerApiMock.GUN_AKIMBO)
  self:throwsExceptionWhenWeaponUsageIsReportedAfterItWasFinished(scoreAttempt, LuaServerApiMock.GUN_ASSAULT)
  self:throwsExceptionWhenWeaponUsageIsReportedAfterItWasFinished(scoreAttempt, LuaServerApiMock.GUN_SUBGUN)
  self:throwsExceptionWhenWeaponUsageIsReportedAfterItWasFinished(scoreAttempt, LuaServerApiMock.GUN_SNIPER)
  self:throwsExceptionWhenWeaponUsageIsReportedAfterItWasFinished(scoreAttempt, LuaServerApiMock.GUN_SHOTGUN)
  self:throwsExceptionWhenWeaponUsageIsReportedAfterItWasFinished(scoreAttempt, LuaServerApiMock.GUN_CARBINE)
  self:throwsExceptionWhenWeaponUsageIsReportedAfterItWasFinished(scoreAttempt, LuaServerApiMock.GUN_GRENADE)

  -- Flag stolen is reported to the ScoreAttempt after it was finished
  local status, result = pcall(scoreAttempt.markFlagStolen, scoreAttempt)
  self:assertFalse(status)
  self:assertTrue(result:is(ScoreAttemptAlreadyFinishedException))
  self:assertEquals("didStealFlag", result:getModifiedAttributeName())

  -- ScoreAttempt should be finished a second time
  status, result = pcall(scoreAttempt.finish, scoreAttempt, 70121)
  self:assertFalse(status)
  self:assertTrue(result:is(ScoreAttemptAlreadyFinishedException))
  self:assertEquals("endTimestamp", result:getModifiedAttributeName())

end

---
-- Checks that an Exception is thrown when a weapon usage is reported to the ScoreAttempt after
-- it was finished.
--
-- @tparam ScoreAttempt _scoreAttempt The finished ScoreAttempt to report the weapon usage to
-- @tparam int _weaponId The ID of the weapon to use for the weapon usage report
--
function TestScoreAttempt:throwsExceptionWhenWeaponUsageIsReportedAfterItWasFinished(_scoreAttempt, _weaponId)

  local ScoreAttemptAlreadyFinishedException = require "GemaScoreManager.ScoreAttempt.Exception.ScoreAttemptAlreadyFinishedException"

  local status, result = pcall(_scoreAttempt.updateWeaponIfRequired, _scoreAttempt, _weaponId)
  self:assertFalse(status)
  self:assertTrue(result:is(ScoreAttemptAlreadyFinishedException))
  self:assertEquals("weaponId", result:getModifiedAttributeName())

end


---
-- Checks that an Exception is thrown when information should be fetched from the ScoreAttempt that
-- requires the ScoreAttempt to be finished while the ScoreAttempt is not finished yet.
--
function TestScoreAttempt:testThrowsExceptionWhenScoreAttemptInformationShouldBeFetchedBeforeItWasFinished()

  local ScoreAttempt = self.testClass

  local ScoreAttemptNotFinishedException = require "GemaScoreManager.ScoreAttempt.Exception.ScoreAttemptNotFinishedException"

  local scoreAttempt = ScoreAttempt(13214, 1)
  self:assertFalse(scoreAttempt:isFinished())

  -- Duration should be fetched before the ScoreAttempt was finished
  local status, result = pcall(scoreAttempt.getDuration, scoreAttempt)
  self:assertFalse(status)
  self:assertTrue(result:is(ScoreAttemptNotFinishedException))
  self:assertEquals("duration", result:getFetchedAttributeName())

end


return TestScoreAttempt
