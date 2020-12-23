---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require "CommandManager.BaseCommand"
local CommandArgument = require "CommandManager.CommandArgument"
local RemainigTimeExtender = require("TimeHandler/RemainingTimeExtender");
local StaticString = require("Output/StaticString");

---
-- Command !extend.
-- Extends the remaining time by a specific amount of time
-- ExtendTimeCommand inherits from BaseCommand
--
-- @type ExtendTimeCommand
--
local ExtendTimeCommand = BaseCommand:extend()


---
-- The remaining time extender
--
-- @tfield RemainingTimeExtender remainingTimeExtender
--
ExtendTimeCommand.remainingTimeExtender = nil


---
-- ExtendTimeCommand constructor.
--
function ExtendTimeCommand:new()

  local numberOfMinutesArgument = CommandArgument(
    StaticString("extendTimeMinutesArgumentName"):getString(),
    false,
    "integer",
    StaticString("extendTimeMinutesArgumentShortName"):getString(),
    StaticString("extendTimeMinutesArgumentDescription"):getString()
  )

  self.super.new(
    self,
    StaticString("extendTimeCommandName"):getString(),
    0,
    StaticString("extendTimeCommandGroupName"):getString(),
    { numberOfMinutesArgument },
    StaticString("extendTimeCommandDescription"):getString(),
    { StaticString("extendTimeCommandAlias1"):getString(),
      StaticString("extendTimeCommandAlias2"):getString() }
  )

  self.remainingTimeExtender = RemainigTimeExtender(20)

end


-- Public Methods

---
-- Extends the remaining time by a specific amount of time.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
-- @raise Error while extending the time
--
function ExtendTimeCommand:execute(_player, _arguments)

  local environmentHandler = self.parentCommandList:getParentGemaMode():getEnvironmentHandler()
  local environment = environmentHandler:getCurrentEnvironment()

  self.remainingTimeExtender:extendTime(_player, environment, _arguments.numberOfMinutes)

  self.output:printTextTemplate(
    "TextTemplate/InfoMessages/Time/TimeExtended",
    { player = _player, numberOfMinutes = _arguments.numberOfMinutes }
  )

end


return ExtendTimeCommand
