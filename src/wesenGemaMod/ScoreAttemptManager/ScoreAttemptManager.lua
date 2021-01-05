---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local ScoreWeaponUpdater = require "ScoreAttemptManager.ScoreWeaponUpdater"
local Server = require "AC-LuaServer.Core.Server"
local ServerEventListener = require "AC-LuaServer.Core.ServerEvent.ServerEventListener"

---
-- Manages the ScoreAttempt's of players.
--
-- @type ScoreAttemptManager
--
local ScoreAttemptManager = BaseExtension:extend()
ScoreAttemptManager:implement(ServerEventListener)

---
-- The list of server events for which this class listens
--
-- @tfield table serverEventListeners
--
ScoreAttemptManager.serverEventListeners = {
  onFlagAction = "onFlagAction",
  onPlayerSpawn = "onPlayerSpawn",
  onPlayerShoot = "onPlayerShoot"
}

---
-- The score weapon updater
--
-- @tfield ScoreWeaponUpdater scoreWeaponUpdater
--
ScoreAttemptManager.scoreWeaponUpdater = nil


---
-- ScoreAttemptManager constructor.
--
function ScoreAttemptManager:new()
  self.super.new(self, "ScoreAttemptManager", "GemaGameMode")
  self.scoreWeaponUpdater = ScoreWeaponUpdater()
end


-- Protected Methods

---
-- Initializes the event listeners.
--
function ScoreAttemptManager:initialize()
  self:registerAllServerEventListeners()
end

---
-- Removes the event listeners.
--
function ScoreAttemptManager:terminate()
  self:unregisterAllServerEventListeners()
end


-- Event Handlers

---
-- Event handler that is called when the state of the flag is changed.
--
-- @tparam int _cn The client number of the player who changed the state
-- @tparam int _action The id of the flag action
-- @tparam int _flag The id of the flag whose state was changed
--
function ScoreAttemptManager:onFlagAction(_cn, _action, _flag)

  if (_action == LuaServerApi.FA_STEAL) then
    local scoreAttempt = self:getPlayerScoreAttemptByCn(_cn)
    scoreAttempt:setDidStealFlag(true)

  elseif (_action == LuaServerApi.FA_PICKUP) then
    local scoreAttempt = self:getPlayerScoreAttemptByCn(_cn)
    if (not scoreAttempt:isFinished() and scoreAttempt:getDidStealFlag() == false) then
      Server.getInstance():getOutput():printTextTemplate(
        "ScoreAttemptManager/Messages/WarningFlagNotStolen",
        {},
        scoreAttempt:getParentPlayer()
      )
    end

  elseif (_action == LuaServerApi.FA_SCORE) then
    local scoreAttempt = self:getPlayerScoreAttemptByCn(_cn)
    if (not scoreAttempt:isFinished()) then
      scoreAttempt:finish()
      self:registerRecord(scoreAttempt)
    end

  end

end

---
-- Event handler which is called when a player spawns.
--
-- @tparam int _cn The client number of the player who spawned
--
function ScoreAttemptManager:onPlayerSpawn(_cn)
  local scoreAttempt = self:getPlayerScoreAttemptByCn(_cn)
  scoreAttempt:start()
  scoreAttempt:setTeamId(getteam(_cn))
end

---
-- Event handler that is called when a player shoots.
--
-- @tparam int _cn The client number of the player who shot
-- @tparam int _weapon The weapon with which the player shot
--
function ScoreAttemptManager:onPlayerShoot(_cn, _weapon)
  self.scoreWeaponUpdater:updateScoreWeapon(self:getPlayerScoreAttemptByCn(_cn), _weapon)
end


-- Private Methods

---
-- Returns the PlayerScoreAttempt of the Player with a given client number.
--
-- @tparam int _cn The client number
--
-- @treturn PlayerScoreAttempt The PlayerScoreAttempt of the Player with the given client number
--
function ScoreAttemptManager:getPlayerScoreAttemptByCn(_cn)
  return Server.getInstance():getPlayerList():getPlayerByCn(_cn):getScoreAttempt()
end

---
-- Adds a record to the maptop and prints the score message.
--
-- @tparam PlayerScoreAttempt scoreAttempt The players score attempt
--
function ScoreAttemptManager:registerRecord(scoreAttempt)

  local mapTop = self.target:getMapTopHandler():getMapTop("main")
  local record = scoreAttempt:getMapRecord(mapTop:getMapRecordList())
  local previousRecord = mapTop:getMapRecordList():getRecordByPlayer(scoreAttempt:getParentPlayer())
  local bestMapScore = mapTop:getMapRecordList():getRecordByRank(1)

  local nextRank = record:getRank() - 1
  if (previousRecord and previousRecord:getRank() < record:getRank()) then
    -- The previous personal best score has a better rank, compare to the next score relative from that rank
    nextRank = previousRecord:getRank() - 1
  end

  local differenceToPreviousRecord, differenceToNextRank, differenceToFirstRank
  if (previousRecord) then
    differenceToPreviousRecord = previousRecord:getMilliseconds() - record:getMilliseconds()
    if (differenceToPreviousRecord < 0) then
      differenceToPreviousRecord = differenceToPreviousRecord * -1
    end
  end

  if (nextRank > 1) then
    -- There is at least one rank between the ScoreAttempt's rank and the first rank
    local nextRankMapScore = mapTop:getMapRecordList():getRecordByRank(nextRank)
    differenceToNextRank = record:getMilliseconds() - nextRankMapScore:getMilliseconds()
  end

  if (bestMapScore) then
    differenceToFirstRank = record:getMilliseconds() - bestMapScore:getMilliseconds()
    if (record:getRank() == 1) then
      differenceToFirstRank = differenceToFirstRank * -1
    end
  end
  local output = Server.getInstance():getOutput()
  output:printTableTemplate(
    "TableTemplate/MapRecord/MapRecordScore",
    { mapRecord = record,
      differenceToOwnBestTime = differenceToPreviousRecord,
      differenceToBestTime = differenceToFirstRank
    }
  )

  if (record:getIsValid()) then
    mapTop:addRecord(record)
  end

end


return ScoreAttemptManager
