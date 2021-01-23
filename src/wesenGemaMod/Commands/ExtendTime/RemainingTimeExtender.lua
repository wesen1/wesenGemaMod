---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local MaximumRemainingTimeExceededException = require "AC-LuaServer.Core.GameHandler.Game.Exception.MaximumRemainingTimeExceededException"
local Object = require "classic"
local Server = require "AC-LuaServer.Core.Server"
local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"

---
-- Extends the remaining time by <x> minutes.
--
-- @type RemainingTimeExtender
--
local RemainingTimeExtender = Object:extend()

---
-- The EventCallback for the game changed events of the GameHandler
--
-- @tfield EventCallback onGameChangedCallback
--
RemainingTimeExtender.onGameChangedCallback = nil

---
-- The number of minutes by which the time can be extended per map
-- The remaining extend minutes will be reset to this value when a map change is detected by this class.
--
RemainingTimeExtender.numberOfExtendMinutesPerMap = nil

---
-- The number of remaining extend minutes that can be used by every player
-- This number will be reset to 20 when the map changes
-- Admins can extend the time by any number of minutes
--
-- @tfield int remainingExtendMinutes
--
RemainingTimeExtender.remainingExtendMinutes = nil


---
-- RemainingTimeExtender constructor.
--
-- @tparam int _numberOfExtendMinutesPerMap The number of extend minutes per map
--
function RemainingTimeExtender:new(_numberOfExtendMinutesPerMap)
  self.numberOfExtendMinutesPerMap = _numberOfExtendMinutesPerMap
  self.onGameChangedCallback = EventCallback({ object = self, methodName = "onGameChanged"})
end


-- Public Methods

---
-- Initializes the event listeners.
--
function RemainingTimeExtender:initialize()

  local gameHandler = Server.getInstance():getGameHandler()
  gameHandler:on("onGameChangedMapChange", self.onGameChangedCallback)
  gameHandler:on("onGameChangedPlayerConnected", self.onGameChangedCallback)

  self.remainingExtendMinutes = self.numberOfExtendMinutesPerMap

end

---
-- Removes the event listeners.
--
function RemainingTimeExtender:terminate()

  local gameHandler = Server.getInstance():getGameHandler()
  gameHandler:off("onGameChangedMapChange", self.onGameChangedCallback)
  gameHandler:off("onGameChangedPlayerConnected", self.onGameChangedCallback)

end

---
-- Extends the time by <x> minutes.
--
-- @tparam Player _player The player who tries to extend the time
-- @tparam int _numberOfExtendMinutes The number of minutes by which the time shall be extended
--
-- @raise Errors while trying to extend the time
--
function RemainingTimeExtender:extendTime(_player, _numberOfExtendMinutes)

  local numberOfExtendMilliseconds = _numberOfExtendMinutes * 60 * 1000

  -- Check the number of extend minutes
  if (_player:getLevel() == 0) then

    if (self.remainingExtendMinutes == 0 or self.remainingExtendMinutes < _numberOfExtendMinutes) then
      error(TemplateException(
        "Commands/ExtendTime/Exceptions/InvalidUnarmedExtendTime",
        { ["remainingExtendMinutes"] = self.remainingExtendMinutes }
      ))
    end

  end

  local currentGame = Server.getInstance():getGameHandler():getCurrentGame()
  local success, exception = pcall(function()
    currentGame:setRemainingTimeInMilliseconds(
      currentGame:getRemainingTimeInMilliseconds() + numberOfExtendMilliseconds
    )
  end)

  if (not success) then
    if (exception.is and exception:is(MaximumRemainingTimeExceededException)) then
      local maximumNumberOfExtendMilliseconds = numberOfExtendMilliseconds - exception:getExceedanceInMilliseconds()
      error(TemplateException(
        "Commands/ExtendTime/Exceptions/InvalidExtendTime",
        {
          ["maximumNumberOfExtendMinutes"] = math.floor(maximumNumberOfExtendMilliseconds / 60000),
          ["millisecondsUntilExtraMinuteCanBeUsed"] = exception:getMillisecondsUntilExtraMinuteCanBeUsed()
        }
      ))
    else
      error(exception)
    end
  end


  -- Subtract the number of extend minutes from the remaining extend minutes
  if (_player:getLevel() == 0) then
    self.remainingExtendMinutes = self.remainingExtendMinutes - _numberOfExtendMinutes
  end

end


-- Event Handlers

---
-- Method that is called after a Game change.
--
function RemainingTimeExtender:onGameChanged()
  self.remainingExtendMinutes = self.numberOfExtendMinutesPerMap
end


return RemainingTimeExtender
