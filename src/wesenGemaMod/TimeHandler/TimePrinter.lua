---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Handles converting times in milliseconds to readable formats.
--
local TimePrinter = setmetatable({}, {});

---
-- The minutes part of the last converted milliseconds
--
-- @tfield int minutes
--
TimePrinter.minutes = nil;

---
-- The seconds part of the last converted milliseconds
--
-- @tfield int seconds
--
TimePrinter.seconds = nil;

---
-- The remaining milliseconds part of the last converted milliseconds
--
-- @tfield int milliseconds
--
TimePrinter.milliseconds = nil;


---
-- TimePrinter constructor.
--
-- @treturn TimePrinter The TimePrinter instance
--
function TimePrinter:__construct()

  local instance = setmetatable({}, {__index = TimePrinter});
  instance.minutes = 0;
  instance.seconds = 0;
  instance.milliseconds = 0;

  return instance;

end

getmetatable(TimePrinter).__call = TimePrinter.__construct;


-- Public Methods

---
-- Returns a time in milliseconds in a custom format.
--
-- Available format specifiers are:
--
-- %i: Minutes
-- %s: Seconds
-- %v: Milliseconds
--
-- You can also specify automatic padding by adding <pad symbol><total number of symbols> between
-- the % and the format specifier id, e.g. "%02i" will print "4" as "04"
--
-- @tparam int _milliseconds The time in milliseconds
-- @tparam string _format The format for the time
--
-- @treturn string The record in the format "Minutes:Seconds,Milliseconds"
--
function TimePrinter:generateTimeString(_milliseconds, _format)

  self:parseMilliseconds(_milliseconds);

  return _format:gsub(
    "(%%.?%d?)(%a)",
    function (_a, _b)
      return self:getFormatSpecifierReplace(_a, _b);
    end
  );

end


-- Private Methods

---
-- Converts a time in milliseconds to minutes, seconds and milliseconds and saves the result in the
-- class attributes "minutes", "seconds" and "milliseconds".
--
-- @tparam int _totalMilliseconds The time in milliseconds
--
function TimePrinter:parseMilliseconds(_totalMilliseconds)

  local milliseconds = math.fmod(_totalMilliseconds, 1000);

  local totalSeconds = (_totalMilliseconds - milliseconds) / 1000;
  local seconds = math.fmod(totalSeconds, 60);

  local minutes = (totalSeconds - seconds) / 60;

  self.milliseconds = milliseconds;
  self.seconds = seconds;
  self.minutes = minutes;

end

---
-- Returns the replacement string for a format specifier.
--
-- @tparam string _formatSpecifierPadding The format specifier padding (e.g. %02)
-- @tparam string _formatSpecifierId The format specifier id (e.g. "i", "s" or "v")
--
-- @treturn string|nil The replacement string or nil if no the format specifier id is invalid
--
function TimePrinter:getFormatSpecifierReplace(_formatSpecifierPadding, _formatSpecifierId)

  local formatSpecifierValue = self:getFormatSpecifierValue(_formatSpecifierId);
  if (formatSpecifierValue) then
    return string.format(_formatSpecifierPadding .. "d", formatSpecifierValue);
  end

end

---
-- Returns the value for a specific format specifier.
--
-- @tparam string _formatSpecifierId The format specifier id
--
-- @treturn int|nil The format specifier value or nil if the format specifier id is invalid
--
function TimePrinter:getFormatSpecifierValue(_formatSpecifierId)

  local formatSpecifierValue = nil;

  if (_formatSpecifierId == "i") then
    formatSpecifierValue = self.minutes;
  elseif (_formatSpecifierId == "s") then
    formatSpecifierValue = self.seconds;
  elseif (_formatSpecifierId == "v") then
    formatSpecifierValue = self.milliseconds;
  end

  return formatSpecifierValue;

end


return TimePrinter;
