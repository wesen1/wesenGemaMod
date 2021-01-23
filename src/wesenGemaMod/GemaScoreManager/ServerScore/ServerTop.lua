---
-- @author wesen
-- @copyright 2020-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local ObjectUtils = require "Util.ObjectUtils"
local ScoreListManager = require "GemaScoreManager.Score.ScoreListManager"

---
-- Manages a single ServerScoreList.
--
-- @type ServerTop
--
local ServerTop = ScoreListManager:extend()

---
-- The MapScoreStorage that will be used to load the initial ServerTop
--
-- @tfield MapScoreStorage mapScoreStorage
--
ServerTop.mapScoreStorage = nil

---
-- The MapScorePointsProvider that will be used to calculate the amount of points for new added MapScore's
--
-- @tfield MapScorePointsProvider mapScorePointsProvider
--
ServerTop.mapScorePointsProvider = nil

---
-- The target MapTop whose added MapScore's will be added to this ServerTop
--
-- @tfield MapTop targetMapTop
--
ServerTop.targetMapTop = nil

---
-- Stores whether this ServerTop was initialized once
--
-- @tfield bool isInitialized
--
ServerTop.isInitialized = nil

---
-- The EventCallback for the "mapScoreAdded" event of the target MapTop
--
-- @tfield EventCallback onMapScoreAddedEventCallback
--
ServerTop.onMapScoreAddedEventCallback = nil


---
-- ServerTop constructor.
--
-- @tparam ServerScoreList _serverScoreList The ServerScoreList to use
-- @tparam MapScoreStorage _mapScoreStorage The MapScoreStorage to use
-- @tparam MapScorePointsProvider _mapScorePointsProvider The MapScorePointsProvider to use
--
function ServerTop:new(_serverScoreList, _mapScoreStorage, _mapScorePointsProvider)
  ScoreListManager.new(self, _serverScoreList)

  self.mapScoreStorage = _mapScoreStorage
  self.mapScorePointsProvider = _mapScorePointsProvider
  self.isInitialized = false
  self.onMapScoreAddedEventCallback = EventCallback({ object = self, methodName = "onMapScoreAdded" })
end


-- Getters and Setters

---
-- Sets the target MapTop.
--
-- @tparam MapTop _mapTop The MapTop whose records should be added to this ServerTop
--
function ServerTop:setTargetMapTop(_mapTop)
  self.targetMapTop = _mapTop
end


-- Public Methods

---
-- Initializes this ServerTop by generating the initial ServerScore's from the MapScoreStorage.
--
function ServerTop:initialize()
  if (not self.isInitialized) then
    -- It's the first time that this ServerTop is initialized
    -- Initialize only once because the ServerTop does not change while the GemaGameMode is not enabled
    self:loadInitialServerScores()
    self.isInitialized = true
  end

  self.targetMapTop:on("mapScoreAdded", self.onMapScoreAddedEventCallback)
end

---
-- Terminates this ServerTop.
--
function ServerTop:terminate()
  self.targetMapTop:off("mapScoreAdded", self.onMapScoreAddedEventCallback)
end


-- Event Handlers

---
-- Event Handler that is called when a MapScore was added to the target MapTop.
--
-- @tparam MapScore _mapScore The MapScore that was added
-- @tparam MapScore|nil _previousMapScore The previous MapScore that was replaced by the MapScore
--
function ServerTop:onMapScoreAdded(_mapScore, _previousMapScore)
  self:addMapScoreToScoreList(_mapScore, _previousMapScore)
end


-- Private Methods

---
-- Generates the initial ServerScore's from the MapRecordStorage.
--
-- @treturn ServerScore[] The list of generated ServerScore's
--
function ServerTop:loadInitialServerScores()

  for mapId, mapScore in self.mapScoreStorage:loadAllMapScores() do

    local mapScorePoints = self.mapScorePointsProvider:getPointsForMapScore(mapScore)
    local score = self.scoreList:getOrCreateScore(mapScore:getPlayer())

    score:addPoints(mapScorePoints)
    score:increaseNumberOfMapScores()
    if (mapScore:getRank() == 1) then
      score:increaseNumberOfBestTimes()
    end

  end

  self.scoreList:sortScores()

end

---
-- Adds a given MapScore to the ServerScoreList.
--
-- @tparam MapScore _mapScore The MapScore to add
-- @tparam MapScore _previousMapScore The previous MapScore that was replaced by the MapScore
--
function ServerTop:addMapScoreToScoreList(_mapScore, _previousMapScore)

  local playerScore = self.scoreList:getOrCreateScore(_mapScore:getPlayer())
  local mapScoreList = self.targetMapTop:getScoreList()
  local serverScorePointsChanged = false

  local previousMapRank = nil
  if (_previousMapScore ~= nil) then
    previousMapRank = _previousMapScore:getRank()
  end

  -- Process the points for the Player who scored
  local mapScorePoints = self.mapScorePointsProvider:getPointsForMapScore(_mapScore)
  if (_previousMapScore ~= nil) then
    mapScorePoints = mapScorePoints - self.mapScorePointsProvider:getPointsForMapScore(_previousMapScore)
  end

  if (mapScorePoints ~= 0) then
    playerScore:addPoints(mapScorePoints)
    serverScorePointsChanged = true
  end

  -- Process the point changes for the Player's whose times were beaten by the new map score
  local playerMapRankChanged = (previousMapRank ~= _mapScore:getRank())
  if (playerMapRankChanged) then

    for rank, mapScore in mapScoreList:iterateByRanks() do
      if (previousMapRank and rank > previousMapRank) then
        break

      elseif (rank > _mapScore:getRank()) then

        local previousBeatenMapScore = ObjectUtils.clone(mapScore)
        previousBeatenMapScore:setRank(mapScore:getRank() - 1)

        local previousMapScorePoints = self.mapScorePointsProvider:getPointsForMapScore(previousBeatenMapScore)
        local currentMapScorePoints = self.mapScorePointsProvider:getPointsForMapScore(mapScore)
        local pointsDifference = previousMapScorePoints - currentMapScorePoints

        if (pointsDifference ~= 0) then
          serverScorePointsChanged = true
          self.scoreList:getScoreByPlayer(mapScore:getPlayer()):subtractPoints(pointsDifference)
        end

      end
    end

  end

  -- Process the number of map scores
  if (_previousMapScore == nil) then
    playerScore:increaseNumberOfMapScores()
  end
  if (_mapScore:getRank() == 1 and playerMapRankChanged) then
    playerScore:increaseNumberOfBestTimes()

    local previousBestMapScore = mapScoreList:getScoreByRank(2)
    if (previousBestMapScore) then
      self.scoreList:getScoreByPlayer(previousBestMapScore:getPlayer()):decreaseNumberOfBestTimes()
    end
  end

  if (serverScorePointsChanged) then
    -- Now resort the ScoreList
    self.scoreList:sortScores()
  end

end


return ServerTop
