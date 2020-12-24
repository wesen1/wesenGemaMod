---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require("Util/Exception");
local Server = require "AC-LuaServer.Core.Server"
local StaticString = require("Output/StaticString");
local TemplateException = require("Util/TemplateException");

---
-- Extends the remaining time by <x> minutes.
--
-- @type RemainingTimeExtender
--
local RemainingTimeExtender = setmetatable({}, {});


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
RemainingTimeExtender.numberOfExtendMinutesPerMap = nil;

---
-- The number of remaining extend minutes that can be used by every player
-- This number will be reset to 20 when the map changes
-- Admins can extend the time by any number of minutes
--
-- @tfield int remainingExtendMinutes
--
RemainingTimeExtender.remainingExtendMinutes = nil;


---
-- RemainingTimeExtender constructor.
--
-- @tparam int _numberOfExtendMinutesPerMap The number of extend minutes per map
--
-- @treturn RemainingTimeExtender The RemainingTimeExtender instance
--
function RemainingTimeExtender:__construct(_numberOfExtendMinutesPerMap)

  local instance = setmetatable({}, {__index = RemainingTimeExtender});

  instance.numberOfExtendMinutesPerMap = _numberOfExtendMinutesPerMap;
  instance.onGameChangedCallback = EventCallback({ object = self, methodName = "onGameChanged"})

  return instance;

end

getmetatable(RemainingTimeExtender).__call = RemainingTimeExtender.__construct;


-- Public Methods

---
-- Initializes the event listeners.
--
function RemainingTimeExtender:initialize()

  local gameHandler = Server.getInstance():getGameHandler()
  gameHandler:on("onGameChangedMapChange", self.onGameChangedCallback)
  gameHandler:on("onGameChangedPlayerConnected", self.onGameChangedCallback)

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

  local numberOfExtendMilliseconds = _numberOfExtendMinutes * 60 * 1000;

  -- Check the number of extend minutes
  if (_player:getLevel() == 0) then

    if (self.remainingExtendMinutes == 0 or self.remainingExtendMinutes < _numberOfExtendMinutes) then
      error(TemplateException(
        "TextTemplate/ExceptionMessages/TimeHandler/InvalidUnarmedExtendTime",
        { ["remainingExtendMinutes"] = self.remainingExtendMinutes }
      ));
    end

  end

  self:validateNumberOfExtendMilliseconds(numberOfExtendMilliseconds);

  local currentGame = Server.getInstance():getGameHandler():getCurrentGame()
  local success, exception = pcall(function()
    currentGame:setRemainingTimeInMilliseconds(
      currentGame:getRemainingTimeInMilliseconds() + numberOfExtendMilliseconds
    )
  end)

  if (not success and exception.is and exception.is(Exception)) then
    error(TemplateException(
      "TextTemplate/ExceptionMessages/TimeHandler/InvalidExtendTime",
      { ["exceptionMessage"] = exception:getMessage() }
    ));
  end


  -- Subtract the number of extend minutes from the remaining extend minutes
  if (_player:getLevel() == 0) then
    self.remainingExtendMinutes = self.remainingExtendMinutes - _numberOfExtendMinutes;
  end

  settimeleftmillis(gettimeleftmillis() + numberOfExtendMilliseconds);

end


-- Event Handlers

---
-- Method that is called after a Game change.
--
function RemainingTimeExtender:onGameChanged()
  self.remainingExtendMinutes = self.numberOfExtendMinutesPerMap
end


return RemainingTimeExtender;
