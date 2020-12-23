---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local ScoreWeaponUpdater = require "ScoreAttemptManager.ScoreWeaponUpdater"
local ServerEventListener = require  "AC-LuaServer.Core.ServerEvent.ServerEventListener"

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
  self.eventCallbacks = {}
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

  if (_action == LuaServerApi.FA_SCORE) then

    local player = Server.getInstance():getPlayerList():getPlayerByCn(_cn)
    local scoreAttempt = player:getScoreAttempt();
    if (not scoreAttempt:isFinished()) then
      scoreAttempt:finish();
      self:registerRecord(scoreAttempt);
    end

  end

end

---
-- Event handler which is called when a player spawns.
--
-- @tparam int _cn The client number of the player who spawned
--
function ScoreAttemptManager:onPlayerSpawn(_cn)

  local player = Server.getInstance():getPlayerList():getPlayerByCn(_cn)

  player:getScoreAttempt():start()
  player:getScoreAttempt():setTeamId(getteam(_cn))

end

---
-- Event handler that is called when a player shoots.
--
-- @tparam int _cn The client number of the player who shot
-- @tparam int _weapon The weapon with which the player shot
--
function ScoreAttemptManager:onPlayerShoot(_cn, _weapon)
  local player = Server.getInstance():getPlayerList():getPlayerByCn(_cn)
  self.scoreWeaponUpdater:updateScoreWeapon(player:getScoreAttempt(), _weapon)
end


-- Private Methods

---
-- Adds a record to the maptop and prints the score message.
--
-- @tparam PlayerScoreAttempt scoreAttempt The players score attempt
--
function ScoreAttemptManager:registerRecord(scoreAttempt)

  local mapTop = self.target:getMapTopHandler():getMapTop("main")
  local record = scoreAttempt:getMapRecord(mapTop:getMapRecordList())

  self.output:printTableTemplate("TableTemplate/MapRecord/MapRecordScore", { mapRecord = record })
  mapTop:addRecord(record)

end


return ScoreAttemptManager
