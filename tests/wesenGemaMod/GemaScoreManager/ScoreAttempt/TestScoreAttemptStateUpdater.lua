---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require "wLuaUnit.TestCase"

---
-- Checks that the ScoreAttemptStateUpdater works as expected.
--
-- @type TestScoreAttemptStateUpdater
--
local TestScoreAttemptStateUpdater = TestCase:extend()


---
-- The require path for the class that is tested by this TestCase
--
-- @tfield string testClassPath
--
TestScoreAttemptStateUpdater.testClassPath = "GemaScoreManager.ScoreAttempt.ScoreAttemptStateUpdater"

---
-- The paths of the classes that the test class depends on
--
-- @tfield table[] dependencyPaths
--
TestScoreAttemptStateUpdater.dependencyPaths = {
  { id = "EventCallback", path = "AC-LuaServer.Core.Event.EventCallback" },
  { id = "LuaServerApi", path = "AC-LuaServer.Core.LuaServerApi", ["type"] = "table" },
  { id = "Server", path = "AC-LuaServer.Core.Server" }
}

---
-- The ScoreAttemptCollection mock that will be injected into the test ScoreAttemptManager instances
--
-- @tfield ScoreAttemptCollection scoreAttemptCollectionMock
--
TestScoreAttemptStateUpdater.scoreAttemptCollectionMock = nil

---
-- The EventCallback mock for the "onPlayerSpawn" server event
--
-- @tfield EventCallback onPlayerSpawnEventCallbackMock
--
TestScoreAttemptStateUpdater.onPlayerSpawnEventCallbackMock = nil

---
-- The EventCallback mock for the "onPlayerShoot" server event
--
-- @tfield EventCallback onPlayerShootEventCallbackMock
--
TestScoreAttemptStateUpdater.onPlayerShootEventCallbackMock = nil

---
-- The EventCallback mock for the "onFlagAction" server event
--
-- @tfield EventCallback onFlagActionEventCallbackMock
--
TestScoreAttemptStateUpdater.onFlagActionEventCallbackMock = nil

---
-- The EventCallback mock for the "onPlayerDisconnect" server event
--
-- @tfield EventCallback onPlayerDisconnectEventCallbackMock
--
TestScoreAttemptStateUpdater.onPlayerDisconnectEventCallbackMock = nil

---
-- The EventCallback mock for the "onPlayerDeath" server event
--
-- @tfield EventCallback onPlayerDeathEventCallbackMock
--
TestScoreAttemptStateUpdater.onPlayerDeathEventCallbackMock = nil

---
-- The EventCallback mock for the "onPlayerTeamChange" server event
--
-- @tfield EventCallback onPlayerTeamChangeEventCallbackMock
--
TestScoreAttemptStateUpdater.onPlayerTeamChangeEventCallbackMock = nil

---
-- The EventCallback mock for the "onMapEnd" server event
--
-- @tfield EventCallback onMapEndEventCallbackMock
--
TestScoreAttemptStateUpdater.onMapEndEventCallbackMock = nil

---
-- The EventCallback mock for the "after_forcedeath" event of the LuaServerApi
--
-- @tfield EventCallback onAfterForceDeathEventCallbackMock
--
TestScoreAttemptStateUpdater.onAfterForceDeathEventCallbackMock = nil

---
-- The EventCallback mock for the "onGameModeStaysEnabledAfterGameChange" event of the GameModeManager
--
-- @tfield EventCallback onGameModeStaysEnabledAfterGameChangeEventCallbackMock
--
TestScoreAttemptStateUpdater.onGameModeStaysEnabledAfterGameChangeEventCallbackMock = nil


---
-- Method that is called before a test is executed.
-- Sets up the mocks.
--
function TestScoreAttemptStateUpdater:setUp()
  TestCase.setUp(self)

  self.scoreAttemptCollectionMock = self:getMock("GemaScoreManager.ScoreAttempt.ScoreAttemptCollection")

  local eventCallbackPath = "AC-LuaServer.Core.Event.EventCallback"
  self.onPlayerSpawnEventCallbackMock = self:getMock(eventCallbackPath, "onPlayerSpawnEventCallbackMock")
  self.onPlayerShootEventCallbackMock = self:getMock(eventCallbackPath, "onPlayerShootEventCallbackMock")
  self.onFlagActionEventCallbackMock = self:getMock(eventCallbackPath, "onFlagActionEventCallbackMock")
  self.onPlayerDisconnectEventCallbackMock = self:getMock(eventCallbackPath, "onPlayerDisconnectEventCallbackMock")
  self.onPlayerDeathEventCallbackMock = self:getMock(eventCallbackPath, "onPlayerDeathEventCallbackMock")
  self.onPlayerTeamChangeEventCallbackMock = self:getMock(eventCallbackPath, "onPlayerTeamChangeEventCallbackMock")
  self.onMapEndEventCallbackMock = self:getMock(eventCallbackPath, "onMapEndEventCallbackMock")
  self.onAfterForceDeathEventCallbackMock = self:getMock(eventCallbackPath, "onAfterForceDeathEventCallbackMock")
  self.onGameModeStaysEnabledAfterGameChangeEventCallbackMock = self:getMock(eventCallbackPath, "onGameModeStaysEnabledAfterGameChangeEventCallbackMock")
end

---
-- Method that is called after a test was executed.
-- Clears the mocks.
--
function TestScoreAttemptStateUpdater:tearDown()
  TestCase.tearDown(self)

  self.scoreAttemptCollectionMock = nil
  self.onPlayerSpawnEventCallbackMock = nil
  self.onPlayerShootEventCallbackMock = nil
  self.onFlagActionEventCallbackMock = nil
  self.onPlayerDisconnectEventCallbackMock = nil
  self.onPlayerDeathEventCallbackMock = nil
  self.onPlayerTeamChangeEventCallbackMock = nil
  self.onMapEndEventCallbackMock = nil
  self.onAfterForceDeathEventCallbackMock = nil
  self.onGameModeStaysEnabledAfterGameChangeEventCallbackMock = nil
end


---
-- Checks that the ScoreAttempt relevant events are handled as expected.
--
function TestScoreAttemptStateUpdater:testCanManageScoreAttempts()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.GUN_ASSAULT = 6
  LuaServerApiMock.FA_PICKUP = 0
  LuaServerApiMock.FA_SCORE = 5
  LuaServerApiMock.FA_STEAL = 1

  local scoreAttemptManager = self:createScoreAttemptManager()

  -- Player spawns
  self.scoreAttemptCollectionMock.startScoreAttempt
                                 :should_be_called_with(3)
                                 :when(
                                   function()
                                     scoreAttemptManager:onPlayerSpawn(3)
                                   end
                                 )

  -- Player shoots
  self.scoreAttemptCollectionMock.updateScoreAttemptWeaponIfRequired
                                 :should_be_called_with(3, LuaServerApiMock.GUN_ASSAULT)
                                 :when(
                                   function()
                                     scoreAttemptManager:onPlayerShoot(3, LuaServerApiMock.GUN_ASSAULT)
                                   end
                                 )

  -- Player finally scores
  self.scoreAttemptCollectionMock.processFlagScore
                                 :should_be_called_with(3)
                                 :when(
                                   function()
                                     scoreAttemptManager:onFlagAction(3, LuaServerApiMock.FA_SCORE)
                                   end
                                 )

  -- A different Player changes teams
  self.scoreAttemptCollectionMock.cancelScoreAttempt
                                 :should_be_called_with(12, "Player changed teams")
                                 :when(
                                   function()
                                     scoreAttemptManager:onPlayerTeamChange(12)
                                   end
                                 )

  -- Player failed a grenade jump and suicided
  self.scoreAttemptCollectionMock.cancelScoreAttempt
                                 :should_be_called_with(12, "Player died")
                                 :when(
                                   function()
                                     scoreAttemptManager:onPlayerDeath(12)
                                   end
                                 )

  -- Game ended
  self.scoreAttemptCollectionMock.cancelAllScoreAttempts
                                 :should_be_called_with("Game ended")
                                 :when(
                                   function()
                                     scoreAttemptManager:onMapEnd()
                                   end
                                 )

  -- Player disconnects
  self.scoreAttemptCollectionMock.cancelScoreAttempt
                                 :should_be_called_with(12, "Player disconnected")
                                 :when(
                                   function()
                                     scoreAttemptManager:onPlayerDisconnect(12)
                                   end
                                 )

  -- Other Player votes the next map
  self.scoreAttemptCollectionMock.cancelAllScoreAttempts
                                 :should_be_called_with("Game changed")
                                 :when(
                                   function()
                                     scoreAttemptManager:onGameModeStaysEnabledAfterGameChange()
                                   end
                                 )

end

---
-- Checks that the ScoreAttemptStateUpdater can be terminated as expected.
--
function TestScoreAttemptStateUpdater:testCanBeTerminated()

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.off = self.mach.mock_method("off")

  local ServerMock = self.dependencyMocks.Server
  local serverMock = self:getMock("AC-LuaServer.Core.Server", "ServerMock")
  local serverEventManagerMock = self:getMock(
    "AC-LuaServer.Core.ServerEvent.ServerEventManager", "ServerEventManagerMock"
  )
  local gameModeManagerMock = self:getMock("AC-LuaServer.Extensions.GameModeManager.GameModeManager")
  gameModeManagerMock.off = self.mach.mock_method("off")

  local scoreAttemptManager = self:createScoreAttemptManager()

  ServerMock.getInstance
            :should_be_called()
            :and_will_return(serverMock)
            :and_then(
              serverMock.getEventManager
                        :should_be_called()
                        :and_will_return(serverEventManagerMock)
            )
            :and_then(
              serverEventManagerMock.off
                                    :should_be_called_with(
                                      "onPlayerSpawn", self.onPlayerSpawnEventCallbackMock
                                    )
                                    :and_also(
                                      serverEventManagerMock.off
                                                            :should_be_called_with(
                                                              "onPlayerShoot",
                                                              self.onPlayerShootEventCallbackMock
                                                            )
                                    )
                                    :and_also(
                                      serverEventManagerMock.off
                                                            :should_be_called_with(
                                                              "onFlagAction",
                                                              self.onFlagActionEventCallbackMock
                                                            )
                                    )
                                    :and_also(
                                      serverEventManagerMock.off
                                                            :should_be_called_with(
                                                              "onPlayerDisconnect",
                                                              self.onPlayerDisconnectEventCallbackMock
                                                            )
                                    )
                                    :and_also(
                                      serverEventManagerMock.off
                                                            :should_be_called_with(
                                                              "onPlayerDeath",
                                                              self.onPlayerDeathEventCallbackMock
                                                            )
                                    )
                                    :and_also(
                                      serverEventManagerMock.off
                                                            :should_be_called_with(
                                                              "onPlayerTeamChange",
                                                              self.onPlayerTeamChangeEventCallbackMock
                                                            )
                                    )
                                    :and_also(
                                      serverEventManagerMock.off
                                                            :should_be_called_with(
                                                              "onMapEnd",
                                                              self.onMapEndEventCallbackMock
                                                            )
                                    )
            )
            :and_also(
              LuaServerApiMock.off
                              :should_be_called_with(
                                "after_forcedeath", self.onAfterForceDeathEventCallbackMock
                              )
            )
            :and_also(
              self:expectExtensionFetching("GameModeManager", gameModeManagerMock)
                  :and_then(
                    gameModeManagerMock.off
                                       :should_be_called_with(
                                         "onGameModeStaysEnabledAfterGameChange",
                                         self.onGameModeStaysEnabledAfterGameChangeEventCallbackMock
                                       )
                  )
            )
            :when(
              function()
                scoreAttemptManager:terminate()
              end
            )

end


-- Private Methods

---
-- Creates and returns a ScoreAttemptStateUpdater instance.
--
-- @treturn ScoreAttemptStateUpdater The created ScoreAttemptStateUpdater instance
--
function TestScoreAttemptStateUpdater:createScoreAttemptManager()

  local ScoreAttemptManager = self.testClass
  local scoreAttemptManager

  local LuaServerApiMock = self.dependencyMocks.LuaServerApi
  LuaServerApiMock.on = self.mach.mock_method("on")

  local ServerMock = self.dependencyMocks.Server
  local serverMock = self:getMock("AC-LuaServer.Core.Server", "ServerMock")
  local serverEventManagerMock = self:getMock(
    "AC-LuaServer.Core.ServerEvent.ServerEventManager", "ServerEventManagerMock"
  )
  local gameModeManagerMock = self:getMock("AC-LuaServer.Extensions.GameModeManager.GameModeManager")
  gameModeManagerMock.on = self.mach.mock_method("on")

  self:expectEventCallbackCreations(
        {
          {
            object = ScoreAttemptManager,
            methodName = "onPlayerDeath"
          },
          nil,
          self.onAfterForceDeathEventCallbackMock,
          TestScoreAttemptStateUpdater.matchEventCallback
        },
        {
          {
            object = ScoreAttemptManager,
            methodName = "onGameModeStaysEnabledAfterGameChange"
          },
          nil,
          self.onGameModeStaysEnabledAfterGameChangeEventCallbackMock,
          TestScoreAttemptStateUpdater.matchEventCallback
        }
      )
      :when(
        function()
          scoreAttemptManager = ScoreAttemptManager(self.scoreAttemptCollectionMock)
        end
      )


  -- Initialize the ScoreAttemptManager
  self:expectEventCallbackCreations(
        {
          { object = scoreAttemptManager, methodName = "onPlayerSpawn"},
          nil,
          self.onPlayerSpawnEventCallbackMock
        },
        {
          { object = scoreAttemptManager, methodName = "onPlayerShoot"},
          nil,
          self.onPlayerShootEventCallbackMock
        },
        {
          { object = scoreAttemptManager, methodName = "onFlagAction"},
          nil,
          self.onFlagActionEventCallbackMock
        },
        {
          { object = scoreAttemptManager, methodName = "onPlayerDisconnect"},
          nil,
          self.onPlayerDisconnectEventCallbackMock
        },
        {
          { object = scoreAttemptManager, methodName = "onPlayerDeath"},
          nil,
          self.onPlayerDeathEventCallbackMock
        },
        {
          { object = scoreAttemptManager, methodName = "onPlayerTeamChange"},
          nil,
          self.onPlayerTeamChangeEventCallbackMock
        },
        {
          { object = scoreAttemptManager, methodName = "onMapEnd"},
          nil,
          self.onMapEndEventCallbackMock
        }
      )
      :and_then(
        ServerMock.getInstance
                  :should_be_called()
                  :and_will_return(serverMock)
                  :and_then(
                    serverMock.getEventManager
                              :should_be_called()
                              :and_will_return(serverEventManagerMock)
                  )
                  :and_then(
                    serverEventManagerMock.on
                                          :should_be_called_with(
                                            "onPlayerSpawn", self.onPlayerSpawnEventCallbackMock
                                          )
                                          :and_also(
                                            serverEventManagerMock.on
                                                                  :should_be_called_with(
                                                                    "onPlayerShoot",
                                                                    self.onPlayerShootEventCallbackMock
                                                                  )
                                          )
                                          :and_also(
                                            serverEventManagerMock.on
                                                                  :should_be_called_with(
                                                                    "onFlagAction",
                                                                    self.onFlagActionEventCallbackMock
                                                                  )
                                          )
                                          :and_also(
                                            serverEventManagerMock.on
                                                                  :should_be_called_with(
                                                                    "onPlayerDisconnect",
                                                                    self.onPlayerDisconnectEventCallbackMock
                                                                  )
                                          )
                                          :and_also(
                                            serverEventManagerMock.on
                                                                  :should_be_called_with(
                                                                    "onPlayerDeath",
                                                                    self.onPlayerDeathEventCallbackMock
                                                                  )
                                          )
                                          :and_also(
                                            serverEventManagerMock.on
                                                                  :should_be_called_with(
                                                                    "onPlayerTeamChange",
                                                                    self.onPlayerTeamChangeEventCallbackMock
                                                                  )
                                          )
                                          :and_also(
                                            serverEventManagerMock.on
                                                                  :should_be_called_with(
                                                                    "onMapEnd",
                                                                    self.onMapEndEventCallbackMock
                                                                  )
                                          )
                  )
      )
      :and_also(
        LuaServerApiMock.on
                        :should_be_called_with("after_forcedeath", self.onAfterForceDeathEventCallbackMock)
      )
      :and_also(
        self:expectExtensionFetching("GameModeManager", gameModeManagerMock)
            :and_then(
              gameModeManagerMock.on
                                 :should_be_called_with(
                                   "onGameModeStaysEnabledAfterGameChange",
                                   self.onGameModeStaysEnabledAfterGameChangeEventCallbackMock
                                 )
            )
      )
      :when(
        function()
          scoreAttemptManager:initialize()
        end
      )

  return scoreAttemptManager

end

---
-- Generates and returns the expectations for a set of EventCallback creations.
--
-- @tparam table[] ... The EventCallback expectation configs
--
-- @treturn table The generated expectations
--
function TestScoreAttemptStateUpdater:expectEventCallbackCreations(...)

  local eventCallbackCreationExpectationConfigs = {...}

  local expectations

  local eventCallbackCreationExpectation
  for _, eventCallbackCreationExpectationConfig in ipairs(eventCallbackCreationExpectationConfigs) do

    eventCallbackCreationExpectation = self:expectEventCallbackCreation(
      eventCallbackCreationExpectationConfig[1],
      eventCallbackCreationExpectationConfig[2],
      eventCallbackCreationExpectationConfig[3],
      eventCallbackCreationExpectationConfig[4]
    )

    if (expectations) then
      expectations:and_also(eventCallbackCreationExpectation)
    else
      expectations = eventCallbackCreationExpectation
    end

  end

  return expectations

end

---
-- Generates and returns the expectations for a single EventCallback creation.
--
-- @tparam table _eventCallbackConfig The expected EventCallback configuration
-- @tparam int _priority The expected priority
-- @tparam EventCallback _eventCallbackMock The EventCallback mock to return
-- @tparam function _matcherFunction The matcher function to use to match the expected and actual EventCallback configurations (optional)
--
-- @treturn table The generated expectations
--
function TestScoreAttemptStateUpdater:expectEventCallbackCreation(_eventCallbackConfig, _priority, _eventCallbackMock, _matcherFunction)

  return self.dependencyMocks.EventCallback.__call
                                           :should_be_called_with(
                                             self.mach.match(_eventCallbackConfig, _matcherFunction),
                                             _priority
                                           )
                                           :and_will_return(_eventCallbackMock)

end

---
-- Matches a specific event callback constructor call.
--
-- The expected object must be a class, the expected methodName a string.
-- This matcher function then checks that the object is an instance of the specified class and that the
-- method names match.
--
-- @treturn bool True if the actual value met the expectations, false otherwise
--
function TestScoreAttemptStateUpdater.matchEventCallback(_expected, _actual)
  return (_actual.object:is(_expected.object) and _actual.methodName == _expected.methodName)
end

---
-- Generates and returns the expectations for a single Extension fetching.
--
-- @tparam string _extensionName The name of the extension that is expected to be fetched
-- @tparam BaseExtension _extensionMock The extension mock to return
--
-- @treturn table The generated expectations
--
function TestScoreAttemptStateUpdater:expectExtensionFetching(_extensionName, _extensionMock)

  local ServerMock = self.dependencyMocks.Server

  local serverMock = self:getMock("AC-LuaServer.Core.Server", "ServerMock")
  local extensionManagerMock = self:getMock("AC-LuaServer.Core.Extension.ExtensionManager")

  return ServerMock.getInstance
                   :should_be_called()
                   :and_will_return(serverMock)
                   :and_then(
                     serverMock.getExtensionManager
                               :should_be_called()
                               :and_will_return(extensionManagerMock)
                   )
                   :and_then(
                     extensionManagerMock.getExtensionByName
                                         :should_be_called_with(_extensionName)
                                         :and_will_return(_extensionMock)
                   )

end


return TestScoreAttemptStateUpdater
