---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require("Util/Exception");

---
-- Extends the remaining time by <x> minutes.
--
-- @type RemainingTimeExtender
--
local RemainingTimeExtender = setmetatable({}, {});


---
-- The number of remaining extend minutes that can be used by every player
-- This number will be reset to 20 when the map changes
-- Admins can extend the time by any number of minutes
--
-- @tfield int remainingExtendMinutes
--
RemainingTimeExtender.remainingExtendMinutes = nil;

---
-- The last environment for which the time was extended
--
-- @tfield Environment lastEnvironment
--
RemainingTimeExtender.lastEnvironment = nil;


---
-- RemainingTimeExtender constructor.
--
-- @treturn RemainingTimeExtender The RemainingTimeExtender instance
--
function RemainingTimeExtender:__construct()
  
  local instance = setmetatable({}, {__index = RemainingTimeExtender});

  instance.lastEnvironment = nil;

  return instance;

end

getmetatable(RemainingTimeExtender).__call = RemainingTimeExtender.__construct;


-- Public Methods

---
-- Extends the time by <x> minutes.
--
-- @tparam Player _player The player who tries to extend the time
-- @tparam Environment _environment The current environment
-- @tparam int _numberOfExtendMinutes The number of minutes by which the time shall be extended
--
-- @raise Errors while trying to extend the time
--
function RemainingTimeExtender:extendTime(_player, _environment, _numberOfExtendMinutes)

  local numberOfExtendMilliseconds = _numberOfExtendMinutes * 60 * 1000;

  -- Check the number of extend minutes
  self:checkAllowedExtendMinutesOfPlayer(_player, _numberOfExtendMinutes);
  self:validateNumberOfExtendMilliseconds(numberOfExtendMilliseconds);

  self:updateLastEnvironment(_environment);
  
  -- Subtract the number of extend minutes from the remaining extend minutes
  if (_player:getLevel() == 0) then
    self.remainingExtendMinutes = self.remainingExtendMinutes - _numberOfExtendMinutes;
  end

  --@todo: Fix number of milliseconds in clients (clockdisplay 1)
  settimeleftmillis(gettimeleftmillis() + numberOfExtendMilliseconds);

end


-- Private Methods

---
-- Checks whether the player is allowed to extend the time by the number of minutes that he tries to extend it by.
--
-- @tparam Player _player The player who tries to extend the time
-- @tparam int _numberOfExtendMinutes The number of extend minutes by which he tries to extend the time
--
-- @raise Error when the player may not extend the time by this number of extend minutes
--
function RemainingTimeExtender:checkAllowedExtendMinutesOfPlayer(_player, _numberOfExtendMinutes)
  
  if (_player:getLevel() == 0) then

    if (self.remainingExtendMinutes == 0) then
      error(Exception("The time may not be further extended. Ask an admin to extend the time."));
    elseif (self.remainingExtendMinutes < _numberOfExtendMinutes) then
      error(Exception("The time may be extended by only " .. self.remainingExtendMinutes .. " more minutes."));
    end
  
  end
  
end

---
-- Checks whether the number of extend milliseconds and the new remaining time are valid.
--
-- @tparam int _numberOfExtendMilliseconds The number of extend milliseconds
--
-- @raise Error when the number of milliseconds is too small
-- @raise Error when the number of milliseconds is too high
--
function RemainingTimeExtender:validateNumberOfExtendMilliseconds(_numberOfExtendMilliseconds)

  -- The extend time command allows only time extension in minutes, so the minimum value is 1 * 60 * 1000
  if (_numberOfExtendMilliseconds < 60000) then
    error(Exception("The number of added minutes may not be smaller than 1."));
  else

    -- Calculate the maximum allowed milliseconds
    -- Admins may extend the time to the maximum possible value

    -- The maximum integer value for signed integers is (2 ^ 31 - 1).
    -- Exceeding this number will result in negative numbers (the number continues at -2147483647).
    local maximumIntegerValue = 2147483647;

    -- The remaining time is calculated as "game limit - milliseconds since game start".
    -- One game means playing one map in this context.
    --
    -- The setmillisecondsremaining function raises the game limit, so that the gap is the desired
    -- number of milliseconds. Therefore the gamemillis (milliseconds since game start) must be
    -- subtracted from the maximum allowed number of extend milliseconds.
    --
    -- Additionally there is a intermission check (check whether the game is finished) that
    -- calculates the number of remaining minutes as "(gamelimit - gamemillis + 60000 - 1)/60000".
    -- If the gamelimit is the maximum integer value and the gamemillis value is less than 60000,
    -- the maximum integer value will be exceeded while the expression is calculated (from left to
    -- right). Therefore the additional milliseconds must be at least 60000.
    local additionalMilliseconds = 60000;
    if (getgamemillis() > additionalMilliseconds) then
      additionalMilliseconds = getgamemillis();
    end

    -- The time left milliseconds must be subtracted too because the time extension is done by
    -- setting the remaining milliseconds to "<time left milliseconds> + <extend milliseconds>"
    local maximumNumberOfExtendMilliseconds = maximumIntegerValue - gettimeleftmillis() - additionalMilliseconds;    

    if (_numberOfExtendMilliseconds > maximumNumberOfExtendMilliseconds) then

      --@todo: Need time parser class for this message and maprecord printer!
      --@todo: Add special error message in case of 0 more minutes possible
      error(Exception("The time remaining may not exceed 35791 minutes."));
    end
  end

end

---
-- Updates the last environment if necessary and resets the remaining extend minutes if the last environment was updated.
--
-- @tparam Environment _environment The current environment
--
function RemainingTimeExtender:updateLastEnvironment(_environment)
  
  if (self.lastEnvironment ~= _environment) then
    self.lastEnvironment = _environment;

    -- @todo: Config value "Number of Extend Minutes per map"
    self.remainingExtendMinutes = 20;
  end

end


return RemainingTimeExtender;
