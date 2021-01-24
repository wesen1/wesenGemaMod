---
-- @author wesen
-- @copyright 2017-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventEmitter = require "AC-LuaServer.Core.Event.EventEmitter"
local ScoreListManager = require "GemaScoreManager.Score.ScoreListManager"

---
-- Manages a single MapScoreList.
--
-- @type MapTop
--
local MapTop = ScoreListManager:extend()
MapTop:implement(EventEmitter)

---
-- The name of the last map for which the MapScore's were loaded
--
-- @tfield string mapName
--
MapTop.mapName = nil

---
-- The MapScore storage that will be used to load MapScore's
--
-- @tfield MapScoreStorage mapScoreStorage
--
MapTop.mapScoreStorage = nil


---
-- MapTop constructor.
--
-- @tparam MapScoreList _mapScoreList The MapScoreList to use
-- @tparam MapScoreStorage _mapScoreStorage The MapScoreStorage to use
--
function MapTop:new(_mapScoreList, _mapScoreStorage)
  ScoreListManager.new(self, _mapScoreList)
  self.mapScoreStorage = _mapScoreStorage

  -- EventEmitter
  self.eventCallbacks = {}
end


-- Getters and setters

---
-- Returns the name of the last map for which the MapScore's were loaded.
--
-- @treturn string The name of the last map for which the MapScore's were loaded
--
function MapTop:getMapName()
  return self.mapName
end


-- Public Methods

---
-- Initializes this ScoreListManager.
--
function MapTop:initialize()
  self.scoreList:clear()
end

---
-- Terminates this ScoreListManager.
--
function MapTop:terminate()
  self.scoreList:clear()
end


---
-- Loads the MapScore's for a given map.
--
-- @tparam string _mapName The name of the map for which to load the corresponding MapScore's
--
function MapTop:loadMapScores(_mapName)

  if (self.mapName ~= _mapName) then
    self.mapName = _mapName
    self.scoreList:clear()

    local numberOfSkippedMapScores = 0
    for mapScore in self.mapScoreStorage:loadMapScores(self.mapName) do

      if (self.scoreList:getScoreByPlayer(mapScore:getPlayer()) == nil) then
        mapScore:setRank(mapScore:getRank() - numberOfSkippedMapScores)
        self.scoreList:addScore(mapScore)
      else
        -- There already is a MapScore for the player (probably because mergeScoresByPlayerName is enabled)
        numberOfSkippedMapScores = numberOfSkippedMapScores + 1
        self.scoreList:addHiddenMapScore(mapScore)
      end

    end
  end

end

---
-- Adds a MapScore to the MapScoreList if it beats the current best time of the Player.
--
-- @tparam MapScore _mapScore The MapScore to check
--
function MapTop:addMapScoreIfBetterThanPreviousPlayerMapScore(_mapScore)

  local previousMapScore = self.scoreList:getScoreByPlayer(_mapScore:getPlayer())
  local previousHiddenMapScore = self.scoreList:getHiddenMapScoreByPlayer(_mapScore:getPlayer())
  local playerMatchesPreviousMapScorePlayer = (previousMapScore and _mapScore:getPlayer():equals(previousMapScore:getPlayer()) or false)

  if (not previousMapScore or previousMapScore:getMilliseconds() > _mapScore:getMilliseconds()) then
    -- It's a new best time for the Player
    if (previousHiddenMapScore) then
      self.scoreList:removeHiddenMapScore(_mapScore:getPlayer())
    end

    if (previousMapScore and not playerMatchesPreviousMapScorePlayer) then
      self.scoreList:addHiddenMapScore(previousMapScore)
    end

    self:addMapScoreToScoreList(_mapScore, previousMapScore)
    self:emit("mapScoreAdded", _mapScore, previousMapScore)

  elseif (not playerMatchesPreviousMapScorePlayer and
          (not previousHiddenMapScore or previousHiddenMapScore:getMilliseconds() > _mapScore:getMilliseconds())) then
    -- The MapScore Player is not the same as the player who scored (IP + name combination does not match),
    -- and it's a new best time for the Player
    self.scoreList:addHiddenMapScore(_mapScore)
    self:emit("hiddenMapScoreAdded", _mapScore, previousMapScore, previousHiddenMapScore)

  else
    self:emit("mapScoreNotAdded", _mapScore, previousMapScore)
  end

end


-- Private Methods

---
-- Adds a MapScore to the MapScoreList.
--
-- @tparam MapScore _mapScore The MapScore to add
-- @tparam MapScore|nil _previousMapScore The previous MapScore for the Player that is replaced by the new MapScore
--
function MapTop:addMapScoreToScoreList(_mapScore, _previousMapScore)

  -- Calculate and set the rank of the new MapScore
  local mapScoreRank = self.scoreList:getNumberOfRanksWithLessThanOrEqualMilliseconds(_mapScore:getMilliseconds()) + 1
  _mapScore:setRank(mapScoreRank)

  -- Move the records between the new rank and the old rank up by one
  -- Note: This must be done before adding the new MapScore because when the new MapScore is added
  --       it will replace the old rank MapScore with the same rank
  local lastAffectedRank = _previousMapScore and _previousMapScore:getRank() - 1 or self.scoreList:getNumberOfScores()
  for i = mapScoreRank, lastAffectedRank, 1 do
    local mapScore = self.scoreList:getScoreByRank(i)
    mapScore:setRank(i + 1)
  end

  -- Add the new MapScore to the ScoreList, by that replacing the previous MapScore for the Player
  self.scoreList:addScore(_mapScore)

  -- Refresh the MapScore ranks cache of the MapScoreList
  self.scoreList:refreshRankScoreCache()

end


return MapTop
