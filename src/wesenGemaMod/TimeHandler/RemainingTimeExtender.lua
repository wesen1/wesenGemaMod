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
-- The name of the last map for which the time was extended
--
-- @tfield string lastMapName
--
RemainingTimeExtender.lastMapName = nil;


---
-- RemainingTimeExtender constructor.
--
-- @treturn RemainingTimeExtender The RemainingTimeExtender instance
--
function RemainingTimeExtender:__construct()
  
  local instance = setmetatable({}, {__index = RemainingTimeExtender});

  instance.lastMapName = nil;

  return instance;

end

getmetatable(RemainingTimeExtender).__call = RemainingTimeExtender.__construct;


-- Public Methods

---
-- Extends the time by <x> minutes.
--
-- @tparam Player _player The player who tries to extend the time
-- @tparam string _mapName The name of the current map
-- @tparam int _numberOfExtendMinutes The number of minutes by which the time shall be extended
--
function RemainingTimeExtender:extendTime(_player, _mapName, _numberOfExtendMinutes)

  local numberOfExtendMilliseconds = _numberOfExtendMinutes * 60 * 1000;

  self:validateNumberOfExtendMilliseconds(numberOfExtendMilliseconds);

  self:updateLastMapName(_mapName);
  self:subtractMinutesFromRemainingExtendMinutes(_player, _numberOfExtendMinutes);
  settimeleftmillis(gettimeleftmillis() + numberOfExtendMilliseconds);

end


-- Private Methods

---
-- Updates the last map name if necessary and resets the remaining extend minutes if the last map name was updated.
--
-- @tparam string _mapName The map name
--
function RemainingTimeExtender:updateLastMapName(_mapName)
  
  if (self.lastMapName ~= _mapName) then
    self.lastMapName = _mapName;

    -- @todo: Config value "Number of Extend Minutes per map"
    self.remainingExtendMinutes = 20;
  end

end

---
-- Subtracts _inputMinutes from the remainig extend minutes.
-- Returns an error if the amount of minutes exceeds the remaining extend minutes.
--
-- @tparam Player _player The player who used !extend
-- @tparam string _mapName The name of the map
-- @tparam int _numberOfExtendMinutes The number of extend minutes
--
-- @raise Error when no extend minutes are remaining and the player level is 0
-- @raise Error when the number of minutes exceeds the remaining extend minutes and the player level is 0
--
function RemainingTimeExtender:subtractMinutesFromRemainingExtendMinutes(_player,  _numberOfExtendMinutes)

  if (_player:getLevel() == 0) then

    if (self.remainingExtendMinutes == 0) then
      error(Exception("The time may not be further extended. Ask an admin to extend the time."));
    elseif (self.remainingExtendMinutes < _numberOfExtendMinutes) then
      error(Exception("The time may be extended by only " .. self.remainingExtendMinutes .. " more minutes."));
    else
      self.remainingExtendMinutes = self.remainingExtendMinutes - _numberOfExtendMinutes;
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

    local timeLeftInMilliseconds = gettimeleftmillis();

    -- (2 ^ 31 - 1) is the highest allowed time left, everything higher will make the current game end
    if (_numberOfExtendMilliseconds >= 2147483647 - timeLeftInMilliseconds) then
      -- The maximum allowed time in minutes is 35791:23.6469999998
      error(Exception("The time remaining may not exceed 35791 minutes."));
    else
      print(timeLeftInMilliseconds + _numberOfExtendMilliseconds);
    end
  end

end


return RemainingTimeExtender;
