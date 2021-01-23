---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ScoreListManagerTestBase = require "wesenGemaMod.GemaScoreManager.Score.ScoreListManagerTestBase"

---
-- Checks that the MapTop works as expected.
--
-- @type TestMapTop
--
local TestMapTop = ScoreListManagerTestBase:extend()

---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestMapTop.testClassPath = "GemaScoreManager.MapScore.MapTop"

---
-- The MapScoreList mock that will be injected into the test MapTop instances
--
-- @tfield MapScoreList mapScoreListMock
--
TestMapTop.mapScoreListMock = nil

---
-- The MapScoreStorage mock that will be injected into the test MapTop instances
--
-- @tfield MapScoreStorage mapScoreStorageMock
--
TestMapTop.mapScoreStorageMock = nil

---
-- Event listener for the "mapScoreAdded" event of the MapTop
--
-- @tfield function onMapScoreAddedListener
--
TestMapTop.onMapScoreAddedListener = nil

---
-- Event listener for the "hiddenMapScoreAdded" event of the MapTop
--
-- @tfield function onHiddenMapScoreAddedListener
--
TestMapTop.onHiddenMapScoreAddedListener = nil

---
-- Event listener for the "mapScoreNotAdded" event of the MapTop
--
-- @tfield function onMapScoreNotAddedListener
--
TestMapTop.onMapScoreNotAddedListener = nil


---
-- Method that is called before a test is executed.
-- Sets up the mocks.
--
function TestMapTop:setUp()
  ScoreListManagerTestBase.setUp(self)

  self.mapScoreListMock = self:createMapScoreListMock()
  self.mapScoreStorageMock = self:createMapScoreStorageMock()

  self.onMapScoreAddedListener = self.mach.mock_function("onMapScoreAddedListener")
  self.onHiddenMapScoreAddedListener = self.mach.mock_function("onHiddenMapScoreAddedListener")
  self.onMapScoreNotAddedListener = self.mach.mock_function("onMapScoreNotAddedListener")
end

---
-- Method that is called after a test was executed.
-- Clears the mocks.
--
function TestMapTop:tearDown()
  ScoreListManagerTestBase.tearDown(self)

  self.mapScoreListMock = nil
  self.mapScoreStorageMock = nil
  self.onMapScoreAddedListener = nil
  self.onHiddenMapScoreAddedListener = nil
  self.onMapScoreNotAddedListener = nil
end


---
-- Checks that the MapTop can be terminated as expected.
--
function TestMapTop:testCanBeTerminated()

  local mapTop = self:createMapTopInstance()

  self.mapScoreListMock.clear
                       :should_be_called()
                       :when(
                         function()
                           mapTop:terminate()
                         end
                       )

end

---
-- Checks that all MapScore's for a map can be loaded.
--
function TestMapTop:testCanLoadMapScoresForMap()

  -- The data sets have numeric keys to make sure that they are executed in the defined order
  local dataSets = {
    [1] = {
      -- No MapScores
      mapName = "gema_expert",
      scores = {}
    },

    [2] = {
      -- Same map as #1
      mapName = "gema_expert",
      expectsNoLoading = true
    },

    [3] = {
      -- No hidden MapScores
      mapName = "gema_la_momie",
      scores = {
        { ["type"] = "normal", rank = 1, expectedRank = 1 },
        { ["type"] = "normal", rank = 2, expectedRank = 2 },
        { ["type"] = "normal", rank = 3, expectedRank = 3 },
        { ["type"] = "normal", rank = 4, expectedRank = 4 },
        { ["type"] = "normal", rank = 5, expectedRank = 5 }
      }
    },

    [4] = {
      -- With hidden MapScores
      mapName = "gema_warm_up",
      scores = {
        { ["type"] = "normal", rank = 1, expectedRank = 1 },
        { ["type"] = "normal", rank = 2, expectedRank = 2 },
        { ["type"] = "hidden", existingMapScoreIndex = 1 },
        { ["type"] = "normal", rank = 4, expectedRank = 3 },
        { ["type"] = "hidden", existingMapScoreIndex = 1 },
        { ["type"] = "hidden", existingMapScoreIndex = 1 },
        { ["type"] = "normal", rank = 7, expectedRank = 4 },
        { ["type"] = "normal", rank = 8, expectedRank = 5 },
        { ["type"] = "hidden", existingMapScoreIndex = 1 },
        { ["type"] = "normal", rank = 10, expectedRank = 6 }
      }
    },

    [5] = {
      -- Same map as #4
      mapName = "gema_warm_up",
      expectsNoLoading = true
    }
  }

  local mapTop = self:createMapTopInstance()
  self:assertNil(mapTop:getMapName())

  for _, dataSet in ipairs(dataSets) do
    self:canLoadMapScoresForMap(mapTop, dataSet)
  end

end


---
-- Checks that all MapScore's for a map can be loaded.
--
-- @tparam MapTop _mapTop The MapTop that should load all MapScore's
-- @tparam mixed[] _dataSet The data set to run
--
function TestMapTop:canLoadMapScoresForMap(_mapTop, _dataSet)

  local mapName = _dataSet["mapName"]
  local scoreMockConfigs = _dataSet["scores"]
  local expectsNoLoading = _dataSet["expectsNoLoading"] or false

  local expectation
  if (not expectsNoLoading) then

    local playerMocks = {}
    local mapScoreMocks = {}

    for i = 1, #scoreMockConfigs, 1 do
      local playerMock = self:createPlayerMock()
      local mapScoreMock = self:createMapScoreMock("MapScore")

      table.insert(playerMocks, playerMock)
      table.insert(mapScoreMocks, mapScoreMock)
    end

    local currentMapScoreIndex = 0
    local mapScoresIteratorMock = function()
      currentMapScoreIndex = currentMapScoreIndex + 1
      if (currentMapScoreIndex <= #mapScoreMocks) then
        return mapScoreMocks[currentMapScoreIndex]
      end
    end

    expectation = self.mapScoreListMock.clear
                                       :should_be_called()
                                       :and_then(
                                         self.mapScoreStorageMock.loadMapScores
                                                                 :should_be_called_with(mapName)
                                                                 :and_will_return(mapScoresIteratorMock)
                                       )

    for i, scoreMockConfig in ipairs(scoreMockConfigs) do

      local mapScoreMock = mapScoreMocks[i]
      local playerMock = playerMocks[i]

      if (scoreMockConfig["type"] == "normal") then

        local mapScoreRank = scoreMockConfig["rank"]
        local expectedMapScoreRank = scoreMockConfig["expectedRank"]

        expectation:and_then(
          mapScoreMock.getPlayer
                      :should_be_called()
                      :and_will_return(playerMock)
                      :and_then(
                        self.mapScoreListMock.getScoreByPlayer
                                             :should_be_called_with(playerMock)
                                             :and_will_return(nil)
                        )
                        :and_then(
                          mapScoreMock.getRank
                                      :should_be_called()
                                      :and_will_return(mapScoreRank)
                        )
                        :and_then(
                          mapScoreMock.setRank
                                      :should_be_called_with(expectedMapScoreRank)
                        )
                        :and_then(
                          self.mapScoreListMock.addScore
                                               :should_be_called_with(mapScoreMock)
                        )
        )

      elseif (scoreMockConfig["type"] == "hidden") then

        local existingMapScoreMockForPlayer = mapScoreMocks[scoreMockConfig["existingMapScoreIndex"]]

        expectation:and_then(
          mapScoreMock.getPlayer
                      :should_be_called()
                      :and_will_return(playerMock)
                      :and_then(
                        self.mapScoreListMock.getScoreByPlayer
                                             :should_be_called_with(playerMock)
                                             :and_will_return(existingMapScoreMockForPlayer)
                      )
                      :and_then(
                        self.mapScoreListMock.addHiddenMapScore
                                             :should_be_called_with(mapScoreMocks[i])
                      )
        )

      end

    end

  end


  local loadMapScoresTest = function()
    _mapTop:loadMapScores(mapName)
    self:assertEquals(mapName, _mapTop:getMapName())
  end

  if (expectation) then
    expectation:when(loadMapScoresTest)
  else
    loadMapScoresTest()
  end

end


---
-- Checks that new MapScore's are processed as expected.
--
function TestMapTop:testAddMapScoreIfBetterThanPreviousPlayerMapScore()

  local dataSets = {

    -- No Previous MapScore, no previous hidden MapScore
    ["No Previous MapScore for Player, no lower ranked MapScore's"] = {
      newMapScore = {
        milliseconds = 44126
      },
      previousMapScore = nil,
      previousHiddenMapScore = nil,

      expectsNewMapScoreAdding = {
        expectsPreviousHiddenMapScoreRemoval = false,
        expectsPreviousMapScoreHiding = false,

        numberOfBetterRanks = 4,
        expectedNewMapScoreRank = 5,
        numberOfScores = 4
      }
    },

    ["No Previous MapScore for Player, with lower ranked MapScore's"] = {
      newMapScore = {
        milliseconds = 44126
      },
      previousMapScore = nil,
      previousHiddenMapScore = nil,

      expectsNewMapScoreAdding = {
        expectsPreviousHiddenMapScoreRemoval = false,
        expectsPreviousMapScoreHiding = false,

        numberOfBetterRanks = 1,
        expectedNewMapScoreRank = 2,
        numberOfScores = 4,
        expectedRankUpdates = {
          [2] = 3,
          [3] = 4,
          [4] = 5
        }
      }
    },


    -- Previous MapScore, no previous hidden MapScore
    ["Previous but slower MapScore for Player, no hidden MapScore, no rank change"] = {
      newMapScore = {
        milliseconds = 44126
      },
      previousMapScore = {
        milliseconds = 100000,
        rank = 5
      },
      previousHiddenMapScore = nil,

      expectsComparisonToPreviousMapScore = {
        playersAreEqual = true
      },
      expectsNewMapScoreAdding = {
        expectsPreviousHiddenMapScoreRemoval = false,
        expectsPreviousMapScoreHiding = false,

        numberOfBetterRanks = 4,
        expectedNewMapScoreRank = 5
      }
    },

    ["Previous but slower MapScore for Player, no hidden MapScore, with rank change"] = {
      newMapScore = {
        milliseconds = 44126
      },
      previousMapScore = {
        milliseconds = 100000,
        rank = 8
      },
      previousHiddenMapScore = nil,

      expectsComparisonToPreviousMapScore = {
        playersAreEqual = true
      },
      expectsNewMapScoreAdding = {
        expectsPreviousHiddenMapScoreRemoval = false,
        expectsPreviousMapScoreHiding = false,

        numberOfBetterRanks = 3,
        expectedNewMapScoreRank = 4,
        expectedRankUpdates = {
          [4] = 5,
          [5] = 6,
          [6] = 7,
          [7] = 8
        }
      }
    },

    ["Previous but equal MapScore for Player, no hidden MapScore"] = {
      newMapScore = {
        milliseconds = 44126
      },
      previousMapScore = {
        milliseconds = 44126
      },
      previousHiddenMapScore = nil,

      expectsComparisonToPreviousMapScore = {
        playersAreEqual = true
      },
      expectsMapScoreNotAdding = true
    },

    ["Previous but faster MapScore for Player, no hidden MapScore"] = {
      newMapScore = {
        milliseconds = 44126
      },
      previousMapScore = {
        milliseconds = 20000
      },
      previousHiddenMapScore = nil,

      expectsComparisonToPreviousMapScore = {
        playersAreEqual = true
      },
      expectsMapScoreNotAdding = true
    },


    -- Previous MapScore, previous hidden MapScore
    ["Previous but slower MapScore for different Player, previous hidden MapScore, no rank change"] = {
      newMapScore = {
        milliseconds = 44126
      },
      previousMapScore = {
        milliseconds = 100000,
        rank = 13
      },
      previousHiddenMapScore = {
        milliseconds = 120000
      },

      expectsComparisonToPreviousMapScore = {
        playersAreEqual = false
      },
      expectsNewMapScoreAdding = {
        expectsPreviousHiddenMapScoreRemoval = true,
        expectsPreviousMapScoreHiding = true,

        numberOfBetterRanks = 12,
        expectedNewMapScoreRank = 13
      }
    },

    ["Previous but slower MapScore for different Player, previous hidden MapScore, with rank change"] = {
      newMapScore = {
        milliseconds = 44126
      },
      previousMapScore = {
        milliseconds = 100000,
        rank = 13
      },
      previousHiddenMapScore = {
        milliseconds = 120000
      },

      expectsComparisonToPreviousMapScore = {
        playersAreEqual = false
      },
      expectsNewMapScoreAdding = {
        expectsPreviousHiddenMapScoreRemoval = true,
        expectsPreviousMapScoreHiding = true,

        numberOfBetterRanks = 4,
        expectedNewMapScoreRank = 5,

        expectedRankUpdates = {
          [5] = 6,
          [6] = 7,
          [7] = 8,
          [8] = 9,
          [9] = 10,
          [10] = 11,
          [11] = 12,
          [12] = 13
        }
      }
    },

    ["Previous but equal MapScore for different Player, no previous hidden MapScore"] = {
      newMapScore = {
        milliseconds = 44126
      },
      previousMapScore = {
        milliseconds = 44126,
        rank = 13
      },
      previousHiddenMapScore = nil,

      expectsComparisonToPreviousMapScore = {
        playersAreEqual = false
      },
      expectsHiddenMapScoreAdding = true
    },

    ["Previous but equal MapScore for different Player, previous but slower hidden MapScore"] = {
      newMapScore = {
        milliseconds = 44126
      },
      previousMapScore = {
        milliseconds = 44126,
        rank = 13
      },
      previousHiddenMapScore = {
        milliseconds = 350000
      },

      expectsComparisonToPreviousMapScore = {
        playersAreEqual = false
      },
      expectsComparisonToPreviousHiddenMapScore = true,
      expectsHiddenMapScoreAdding = true
    },

    ["Previous but equal MapScore for different Player, previous but equal hidden MapScore"] = {
      newMapScore = {
        milliseconds = 44126
      },
      previousMapScore = {
        milliseconds = 44126,
        rank = 13
      },
      previousHiddenMapScore = {
        milliseconds = 44126
      },

      expectsComparisonToPreviousMapScore = {
        playersAreEqual = false
      },
      expectsComparisonToPreviousHiddenMapScore = true,
      expectsMapScoreNotAdding = true
    },

    ["Previous but equal MapScore for different Player, previous but faster hidden MapScore"] = {
      newMapScore = {
        milliseconds = 44126
      },
      previousMapScore = {
        milliseconds = 44126,
        rank = 13
      },
      previousHiddenMapScore = {
        milliseconds = 5000
      },

      expectsComparisonToPreviousMapScore = {
        playersAreEqual = false
      },
      expectsComparisonToPreviousHiddenMapScore = true,
      expectsMapScoreNotAdding = true
    },

    ["Previous but faster MapScore for different Player, no previous hidden MapScore"] = {
      newMapScore = {
        milliseconds = 44126
      },
      previousMapScore = {
        milliseconds = 40000,
        rank = 5
      },
      previousHiddenMapScore = nil,

      expectsComparisonToPreviousMapScore = {
        playersAreEqual = false
      },
      expectsHiddenMapScoreAdding = true
    },

    ["Previous but faster MapScore for different Player, previous but slower hidden MapScore"] = {
      newMapScore = {
        milliseconds = 44126
      },
      previousMapScore = {
        milliseconds = 40000,
        rank = 5
      },
      previousHiddenMapScore = {
        milliseconds = 120000
      },

      expectsComparisonToPreviousMapScore = {
        playersAreEqual = false
      },
      expectsComparisonToPreviousHiddenMapScore = true,
      expectsHiddenMapScoreAdding = true
    },

    ["Previous but faster MapScore for different Player, previous but equal hidden MapScore"] = {
      newMapScore = {
        milliseconds = 44126
      },
      previousMapScore = {
        milliseconds = 40000,
        rank = 5
      },
      previousHiddenMapScore = {
        milliseconds = 44126
      },

      expectsComparisonToPreviousMapScore = {
        playersAreEqual = false
      },
      expectsComparisonToPreviousHiddenMapScore = true,
      expectsMapScoreNotAdding = true
    },

    ["Previous but faster MapScore for different Player, previous but faster hidden MapScore"] = {
      newMapScore = {
        milliseconds = 44126
      },
      previousMapScore = {
        milliseconds = 40000,
        rank = 5
      },
      previousHiddenMapScore = {
        milliseconds = 12345
      },

      expectsComparisonToPreviousMapScore = {
        playersAreEqual = false
      },
      expectsComparisonToPreviousHiddenMapScore = true,
      expectsMapScoreNotAdding = true
    },
  }

  for _, dataSet in pairs(dataSets) do
    self:addsMapScoreIfBetterThanPreviousPlayerMapScore(dataSet)
  end

end

---
-- Checks that new MapScore's are processed as expected.
--
-- @tparam mixed[] _dataSet The data set to run
--
function TestMapTop:addsMapScoreIfBetterThanPreviousPlayerMapScore(_dataSet)

  local mapTop = self:createMapTopInstance()

  local newMapScorePlayerMock = self:createPlayerMock()
  local newMapScoreMock = self:createMapScoreMock("NewMapScore")

  local previousMapScorePlayerMock, previousMapScoreMock
  if (_dataSet["previousMapScore"] ~= nil) then
    previousMapScorePlayerMock = self:createPlayerMock()
    previousMapScoreMock = self:createMapScoreMock("PreviousMapScore")
  end

  local previousHiddenMapScoreMock
  if (_dataSet["previousHiddenMapScore"] ~= nil) then
    previousHiddenMapScoreMock = self:createMapScoreMock("PreviousHiddenMapScore")
  end

  local expectations = newMapScoreMock.getPlayer
                                      :may_be_called()
                                      :multiple_times(10)
                                      :and_will_return(newMapScorePlayerMock)
                                      :and_also(
                                        newMapScoreMock.getMilliseconds
                                                       :may_be_called()
                                                       :multiple_times(10)
                                                       :and_will_return(
                                                         _dataSet["newMapScore"]["milliseconds"]
                                                       )
                                      )
                                      :and_also(
                                        self.mapScoreListMock.getScoreByPlayer
                                                             :should_be_called_with(newMapScorePlayerMock)
                                                             :and_will_return(previousMapScoreMock)
                                      )
                                      :and_also(
                                        self.mapScoreListMock.getHiddenMapScoreByPlayer
                                                             :should_be_called_with(newMapScorePlayerMock)
                                                             :and_will_return(previousHiddenMapScoreMock)
                                      )

  if (_dataSet["expectsComparisonToPreviousMapScore"]) then

    local playersAreEqual = _dataSet["expectsComparisonToPreviousMapScore"]["playersAreEqual"]
    expectations:and_also(
      previousMapScoreMock.getPlayer
                          :may_be_called()
                          :multiple_times(10)
                          :and_will_return(previousMapScorePlayerMock)
                          :and_also(
                            newMapScorePlayerMock.equals
                                                 :should_be_called_with(previousMapScorePlayerMock)
                                                 :and_will_return(playersAreEqual)
                          )
                )
                :and_also(
                  previousMapScoreMock.getMilliseconds
                                      :may_be_called()
                                      :multiple_times(10)
                                      :and_will_return(_dataSet["previousMapScore"]["milliseconds"])
                )
                :and_also(
                  previousMapScoreMock.getRank
                                      :may_be_called()
                                      :multiple_times(10)
                                      :and_will_return(_dataSet["previousMapScore"]["rank"])
                )
  end

  if (_dataSet["expectsComparisonToPreviousHiddenMapScore"]) then
    expectations:and_also(
      previousHiddenMapScoreMock.getMilliseconds
                                :may_be_called()
                                :multiple_times(10)
                                :and_will_return(_dataSet["previousHiddenMapScore"]["milliseconds"])
                )
  end

  if (_dataSet["expectsNewMapScoreAdding"]) then

    if (_dataSet["expectsNewMapScoreAdding"]["expectsPreviousHiddenMapScoreRemoval"]) then
      expectations:and_also(
        self.mapScoreListMock.removeHiddenMapScore
                             :should_be_called_with(newMapScorePlayerMock)
      )
    end

    if (_dataSet["expectsNewMapScoreAdding"]["expectsPreviousMapScoreHiding"]) then
      expectations:and_also(
        self.mapScoreListMock.addHiddenMapScore
                             :should_be_called_with(previousMapScoreMock)
      )
    end

    expectations:and_also(
      self.mapScoreListMock.getNumberOfRanksWithLessThanOrEqualMilliseconds
                           :should_be_called_with(_dataSet["newMapScore"]["milliseconds"])
                           :and_will_return(_dataSet["expectsNewMapScoreAdding"]["numberOfBetterRanks"])
                )
                :and_also(
                  newMapScoreMock.setRank
                                 :should_be_called_with(
                                   _dataSet["expectsNewMapScoreAdding"]["expectedNewMapScoreRank"]
                                 )
                )

    if (_dataSet["expectsNewMapScoreAdding"]["numberOfScores"]) then
        expectations:and_also(
          self.mapScoreListMock.getNumberOfScores
                               :should_be_called()
                               :and_will_return(_dataSet["expectsNewMapScoreAdding"]["numberOfScores"])
                    )
    end

    if (_dataSet["expectsNewMapScoreAdding"]["expectedRankUpdates"]) then

      for oldRank, newRank in pairs(_dataSet["expectsNewMapScoreAdding"]["expectedRankUpdates"]) do

        local mapScoreMock = self:createMapScoreMock("MapScore")
        expectations:and_also(
          self.mapScoreListMock.getScoreByRank
                               :should_be_called_with(oldRank)
                               :and_will_return(mapScoreMock)
                    )
                    :and_also(
                      mapScoreMock.setRank
                                  :should_be_called_with(newRank)
                    )

      end

    end

    expectations:and_then(
        self.mapScoreListMock.addScore
                             :should_be_called_with(newMapScoreMock)
                )
                :and_also(
                  self.mapScoreListMock.refreshRankScoreCache
                                       :should_be_called()
                )
                :and_also(
                  self.onMapScoreAddedListener:should_be_called_with(newMapScoreMock, previousMapScoreMock)
                )


  elseif (_dataSet["expectsHiddenMapScoreAdding"]) then

    expectations:and_also(
      self.mapScoreListMock.addHiddenMapScore
                           :should_be_called_with(newMapScoreMock)
                )
                :and_then(
                  self.onHiddenMapScoreAddedListener:should_be_called_with(
                    newMapScoreMock, previousMapScoreMock, previousHiddenMapScoreMock
                  )
                )

  elseif (_dataSet["expectsMapScoreNotAdding"]) then
    expectations:and_also(
      self.onMapScoreNotAddedListener
          :should_be_called_with(newMapScoreMock, previousMapScoreMock)
    )
  end


  expectations:when(
    function()
      mapTop:addMapScoreIfBetterThanPreviousPlayerMapScore(newMapScoreMock)
    end
  )

end


-- Protected Methods

---
-- Creates and returns a ScoreListManager instance.
--
-- @tparam ScoreList The ScoreList to create the ScoreListManager instance with
--
-- @treturn ScoreListManager The created ScoreListManager instance
--
function TestMapTop:createScoreListManagerInstance(_scoreList)
  local MapTop = self.testClass
  return MapTop(_scoreList, self.mapScoreStorageMock)
end

---
-- Creates and returns a ScoreList mock.
--
-- @treturn ScoreList The created ScoreList mock
--
function TestMapTop:createScoreListMock()
  return self:createMapScoreListMock()
end


-- Private Methods

---
-- Creates, initializes and returns a MapTop instance.
-- Also attaches the event listeners to the created MapTop instance.
--
-- @treturn MapTop The created MapTop instance
--
function TestMapTop:createMapTopInstance()

  local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
  local MapTop = self.testClass
  local mapTop = MapTop(self.mapScoreListMock, self.mapScoreStorageMock)

  mapTop:on("mapScoreAdded", EventCallback(function(...)
    self.onMapScoreAddedListener(...)
  end))
  mapTop:on("hiddenMapScoreAdded", EventCallback(function(...)
    self.onHiddenMapScoreAddedListener(...)
  end))
  mapTop:on("mapScoreNotAdded", EventCallback(function(...)
    self.onMapScoreNotAddedListener(...)
  end))

  self.mapScoreListMock.clear
                       :should_be_called()
                       :when(
                         function()
                           mapTop:initialize()
                         end
                       )

  return mapTop

end

---
-- Creates and returns a MapScoreList mock.
--
-- @treturn MapScoreList The created MapScoreList mock
--
function TestMapTop:createMapScoreListMock()

  local mapScoreListMock = self:getMock("GemaScoreManager.MapScore.MapScoreList", "MapScoreList")

  -- Add methods that are defined in the base ScoreList
  mapScoreListMock.getScoreByRank = self.mach.mock_method("MapScoreList:getScoreByRank")
  mapScoreListMock.getScoreByPlayer = self.mach.mock_method("MapScoreList:getScoreByPlayer")
  mapScoreListMock.addScore = self.mach.mock_method("MapScoreList:addScore")
  mapScoreListMock.refreshRankScoreCache = self.mach.mock_method("MapScoreList:refreshRankScoreCache")
  mapScoreListMock.getNumberOfScores = self.mach.mock_method("MapScoreList:getNumberOfScores")

  return mapScoreListMock

end

---
-- Creates and returns a MapScoreStorage mock.
--
-- @treturn MapScoreStorage The created MapScoreStorage mock
--
function TestMapTop:createMapScoreStorageMock()
  return {
    loadMapScores = self.mach.mock_method("MapScoreStorage:loadMapScores")
  }
end

---
-- Creates and returns a Player mock.
--
-- @treturn Player The created Player mock
--
function TestMapTop:createPlayerMock()
  return {
    equals = self.mach.mock_method("Player:equals")
  }
end

---
-- Creates and returns a MapScore mock.
--
-- @tparam string _mockName The name for the MapScore mock
--
-- @treturn MapScore The created MapScore mock
--
function TestMapTop:createMapScoreMock(_mockName)

  local mapScoreMock = self:getMock("GemaScoreManager.MapScore.MapScore", _mockName)

  -- Add methods that are defined in the base Score
  mapScoreMock.getPlayer = self.mach.mock_method(_mockName .. ":getPlayer")
  mapScoreMock.getRank = self.mach.mock_method(_mockName .. ":getRank")
  mapScoreMock.setRank = self.mach.mock_method(_mockName .. ":setRank")

  return mapScoreMock

end


return TestMapTop
