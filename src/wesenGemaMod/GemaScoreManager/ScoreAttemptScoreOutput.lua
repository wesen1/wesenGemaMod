---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local Object = require "classic"
local Server = require "AC-LuaServer.Core.Server"

---
-- Prints information about ScoreAttempt MapScore's to the Player's.
--
-- @type ScoreAttemptScoreOutput
--
local ScoreAttemptScoreOutput = Object:extend()


---
-- The EventCallback for the "flagPickedUpWithoutStealing" event of the ScoreAttemptManager
--
-- @tfield EventCallback onFlagPickedUpWithoutStealingEventCallback
--
ScoreAttemptScoreOutput.onFlagPickedUpWithoutStealingEventCallback = nil

---
-- The EventCallback for the "mapScoreAdded" event of the main MapTop
--
-- @tfield EventCallback onMapScoreAddedEventCallback
--
ScoreAttemptScoreOutput.onMapScoreAddedEventCallback = nil

---
-- The EventCallback for the "hiddenMapScoreAdded" event of the main MapTop
--
-- @tfield EventCallback onHiddenMapScoreAddEventCallback
--
ScoreAttemptScoreOutput.onHiddenMapScoreAddEventCallback = nil

---
-- The EventCallback for the "mapScoreNotAdded" event of the main MapTop
--
-- @tfield EventCallback onMapScoreNotAddedEventCallback
--
ScoreAttemptScoreOutput.onMapScoreNotAddedEventCallback = nil

---
-- The EventCallback for the "invalidScoreAttemptFinished" event of the GemaScoreManager
--
-- @tfield EventCallback onInvalidScoreAttemptFinished
--
ScoreAttemptScoreOutput.onInvalidScoreAttemptFinished = nil


---
-- ScoreAttemptScoreOutput constructor.
--
function ScoreAttemptScoreOutput:new()

  self.onFlagPickedUpWithoutStealingEventCallback = EventCallback({ object = self, methodName = "onFlagPickedUpWithoutStealing" })
  self.onMapScoreAddedEventCallback = EventCallback({ object = self, methodName = "onMapScoreAdded" })
  self.onHiddenMapScoreAddEventCallback = EventCallback({ object = self, methodName = "onHiddenMapScoreAdded" })
  self.onMapScoreNotAddedEventCallback = EventCallback({ object = self, methodName = "onMapScoreNotAdded" })
  self.onInvalidScoreAttemptFinished = EventCallback({ object = self, methodName = "onInvalidScoreAttemptFinished" })

end


-- Public Methods

---
-- Initializes the event listeners.
--
-- @tparam GemaScoreManager _gemaScoreManager The GemaScoreManager for whose events to listen
--
function ScoreAttemptScoreOutput:initialize(_gemaScoreManager)

  local scoreAttemptManager = _gemaScoreManager:getScoreAttemptManager()
  local mainMapTop = _gemaScoreManager:getMapTopManager():getMapTop("main")

  scoreAttemptManager:getScoreAttemptCollection():on("flagPickedUpWithoutStealing", self.onFlagPickedUpWithoutStealingEventCallback)
  mainMapTop:on("mapScoreAdded", self.onMapScoreAddedEventCallback)
  mainMapTop:on("hiddenMapScoreAdded", self.onHiddenMapScoreAddEventCallback)
  mainMapTop:on("mapScoreNotAdded", self.onMapScoreNotAddedEventCallback)
  _gemaScoreManager:on("invalidScoreAttemptFinished", self.onInvalidScoreAttemptFinished)

end

---
-- Terminates the event listeners.
--
-- @tparam GemaScoreManager _gemaScoreManager The GemaScoreManager to remove event listeners from
--
function ScoreAttemptScoreOutput:terminate(_gemaScoreManager)

  local scoreAttemptManager = _gemaScoreManager:getScoreAttemptManager()
  local mainMapTop = _gemaScoreManager:getMapTopManager():getMapTop("main")

  scoreAttemptManager:getScoreAttemptCollection():off("flagPickedUpWithoutStealing", self.onFlagPickedUpWithoutStealingEventCallback)
  mainMapTop:off("mapScoreAdded", self.onMapScoreAddedEventCallback)
  mainMapTop:off("hiddenMapScoreAdded", self.onHiddenMapScoreAddEventCallback)
  mainMapTop:off("mapScoreNotAdded", self.onMapScoreNotAddedEventCallback)
  _gemaScoreManager:off("invalidScoreAttemptFinished", self.onInvalidScoreAttemptFinished)

end


-- Event Handlers

---
-- Event handler that is called when a player picked up the flag without stealing it from its original position.
--
-- @tparam int _cn The client number of the player who picked up the flag without stealing it
--
function ScoreAttemptScoreOutput:onFlagPickedUpWithoutStealing(_cn)

  Server.getInstance():getOutput():printTextTemplate(
    "GemaScoreManager/ScoreAttempt/WarningFlagNotStolen",
    {},
    Server.getInstance():getPlayerList():getPlayerByCn(_cn)
  )

end

---
-- Event handler that is called when a MapScore was added to the main MapTop.
--
-- @tparam MapScore _mapScore The MapScore that was added to the main MapTop
-- @tparam MapScore|nil _previousMapScore The previous MapScore that was replaced by the new MapScore
--
function ScoreAttemptScoreOutput:onMapScoreAdded(_mapScore, _previousMapScore)
  self:outputMapScore(_mapScore, _previousMapScore, true, false)
end

---
-- Event handler that is called when a hidden MapScore was added to the main MapTop.
--
-- @tparam MapScore _mapScore The hidden MapScore that was added to the main MapTop
-- @tparam MapScore _previousMapScore The previous MapScore that prevented the new MapScore from being added as a non hidden MapScore
--
function ScoreAttemptScoreOutput:onHiddenMapScoreAdded(_mapScore, _previousMapScore)
  self:outputMapScore(_mapScore, _previousMapScore, true, true)
end

---
-- Event handler that is called when a MapScore was processed but not added to the main MapTop.
--
-- @tparam MapScore _mapScore The MapScore that was not added
-- @tparam MapScore _previousMapScore The previous MapScore that prevented the new MapScore from being added
--
function ScoreAttemptScoreOutput:onMapScoreNotAdded(_mapScore, _previousMapScore)
  self:outputMapScore(_mapScore, _previousMapScore, true, false)
end

---
-- Event handler that is called when a Player's finished ScoreAttempt is invalid.
--
-- @tparam MapScore _mapScore The MapScore that would have been added for the Player if the ScoreAttempt was valid
--
function ScoreAttemptScoreOutput:onInvalidScoreAttemptFinished(_mapScore)
  -- The previous MapScore is set to nil because the difference to it is not shown
  self:outputMapScore(_mapScore, nil, false, false)
end


-- Private Methods

---
-- Outputs a ScoreAttempt MapScore to the Player's.
--
-- @tparam MapScore _mapScore The MapScore to output
-- @tparam MapScore|nil _previousMapScore The previous MapScore for the score Player to calculate differences to
-- @tparam bool _isValid True if the MapScore is valid, false otherwise
-- @tparam bool _isHiddenMapScore True if the MapScore is a hidden MapScore, false otherwise
--
function ScoreAttemptScoreOutput:outputMapScore(_mapScore, _previousMapScore, _isValid, _isHiddenMapScore)

  local gemaScoreManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaScoreManager")
  local mainMapTop = gemaScoreManager:getMapTopManager():getMapTop("main")

  -- Fetch the total number of MapScore's (including the new MapScore)
  local totalNumberOfMapScores = mainMapTop:getScoreList():getNumberOfScores()

  -- Calculate the differences to the previous MapScore and to the first rank
  local differenceToPreviousScore, differenceToFirstRank
  if (_isValid) then

    -- Calculate the difference to the previous MapScore
    if (_previousMapScore) then
      differenceToPreviousScore = _mapScore:getMilliseconds() - _previousMapScore:getMilliseconds()
    end

    -- Calculate the difference to the best MapScore
    local bestMapScore = self:findBestMapScore(_mapScore, _previousMapScore, mainMapTop)
    if (bestMapScore) then
      differenceToFirstRank = _mapScore:getMilliseconds() - bestMapScore:getMilliseconds()
      if (_mapScore:getRank() == 1) then
        differenceToFirstRank = differenceToFirstRank * -1
      end
    end

  end

  -- Print the score time and the comparison to the old personal best time to all players
  local output = Server.getInstance():getOutput()
  output:printTableTemplate(
    "GemaScoreManager/ScoreAttemptScoreOutput/ScoreAttemptScore",
    { mapScore = _mapScore,
      totalNumberOfMapScores = totalNumberOfMapScores,
      differenceToOwnBestTime = differenceToPreviousScore,
      differenceToBestTime = differenceToFirstRank,
      isMapScoreValid = _isValid
    }
  )

  if (_isValid) then
    -- Print the comparison to the next and first rank only to the player who scored

    local differenceToNextRank
    local nextRankMapScore = self:findNextRankMapScore(_mapScore, _previousMapScore, mainMapTop)
    if (nextRankMapScore and nextRankMapScore:getRank() > 1) then
      -- There is at least one rank between the ScoreAttempt's rank and the first rank
      differenceToNextRank = _mapScore:getMilliseconds() - nextRankMapScore:getMilliseconds()
    end

    if (nextRankMapScore and nextRankMapScore:getRank() >= 1) then
      output:printTextTemplate(
        "GemaScoreManager/ScoreAttemptScoreOutput/AdditionalScoreTimeDifferences",
        {
          nextRank = nextRankMapScore:getRank(),
          differenceToNextRank = differenceToNextRank,
          differenceToFirstRank = differenceToFirstRank
        },
        _mapScore:getPlayer()
      )
    end

  end

  if (_isHiddenMapScore) then
    -- Print a info message to the player that tells him that his MapScore was saved but a better
    -- score for his player name exists
    output:printTextTemplate(
      "GemaScoreManager/ScoreAttemptScoreOutput/HiddenMapScoreAdded",
      {
        playerName = _mapScore:getPlayer():getName()
      },
      _mapScore:getPlayer()
    )
  end

end

---
-- Finds and returns the best MapScore to compare a new MapScore to.
--
-- @tparam MapScore _mapScore The new MapScore that is needed to check if the old best score is now 2nd
-- @tparam MapScore|nil _previousMapScore The previous MapScore that is needed to check if the previous MapScore was 1st
-- @tparam MapTop _mapTop The MapTop to load the best MapScore from if necessary
--
-- @treturn MapScore|nil The best MapScore
--
function ScoreAttemptScoreOutput:findBestMapScore(_mapScore, _previousMapScore, _mapTop)

  local bestMapScore
  if (_previousMapScore and _previousMapScore:getRank() == 1) then
    bestMapScore = _previousMapScore
  elseif (_mapScore:getRank() == 1) then
    bestMapScore = _mapTop:getScoreList():getScoreByRank(2)
  else
    bestMapScore = _mapTop:getScoreList():getScoreByRank(1)
  end

  return bestMapScore

end

---
-- Finds and returns the next rank MapScore to compare a new MapScore to.
--
-- @tparam MapScore _mapScore The new MapScore
-- @tparam MapScore|nil _previousMapScore The previous MapScore
-- @tparam MapTop _mapTop The MapTop to load the next rank MapScore from if necessary
--
-- @treturn MapScore|nil The next rank MapScore
--
function ScoreAttemptScoreOutput:findNextRankMapScore(_mapScore, _previousMapScore, _mapTop)

  local nextRank
  if (_previousMapScore and
      (_mapScore:getRank() == nil or _previousMapScore:getRank() < _mapScore:getRank())) then
    -- The previous personal best score has a better rank, compare to the next score relative from that rank
    nextRank = _previousMapScore:getRank() - 1

  elseif (_mapScore:getRank() ~= nil) then
    nextRank = _mapScore:getRank() - 1
  end

  if (nextRank and nextRank > 0) then
    return _mapTop:getScoreList():getScoreByRank(nextRank)
  end

end


return ScoreAttemptScoreOutput
