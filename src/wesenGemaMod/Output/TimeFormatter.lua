---
-- @author wesen
-- @copyright 2018-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Handles converting of times in milliseconds to readable formats.
--
-- @type TimeFormatter
--
local TimeFormatter = Object:extend()

-- The available trimming mode for leading time parts whose value is 0
TimeFormatter.LEADING_ZERO_TIME_PART_TRIMMING_NONE = 1
TimeFormatter.LEADING_ZERO_TIME_PART_TRIMMING_UNTIL_FIRST_NON_WHITESPACE = 2

---
-- The custom time unit names to use when a custom time unit name is requested
--
-- This table may have one or more of the following fields:
-- {
--   minutes = <minutes time unit name>,
--   seconds = <seconds time unit name>,
--   milliseconds = <milliseconds time unit name>
-- }
--
-- @tfield string[] customTimeUnitNames
--
TimeFormatter.customTimeUnitNames = nil

---
-- The minutes part of the last converted milliseconds
--
-- @tfield int minutes
--
TimeFormatter.minutes = nil

---
-- The seconds part of the last converted milliseconds
--
-- @tfield int seconds
--
TimeFormatter.seconds = nil

---
-- The remaining milliseconds part of the last converted milliseconds
--
-- @tfield int milliseconds
--
TimeFormatter.milliseconds = nil

---
-- The current trimming mode for leading time parts whose value is 0
--
-- @tfield int leadingZeroTimePartTrimmingMode
--
TimeFormatter.leadingZeroTimePartTrimmingMode = nil

---
-- Stores whether a non zero time part was found during the current time string generation
--
-- @tfield bool nonZeroTimePartFound
--
TimeFormatter.nonZeroTimePartFound = nil


---
-- TimeFormatter constructor.
--
-- @tparam string[] _customTimeUnitNames The custom time unit names to use (optional)
--
function TimeFormatter:new(_customTimeUnitNames)
  self.customTimeUnitNames = _customTimeUnitNames or {}
  self.minutes = 0
  self.seconds = 0
  self.milliseconds = 0
end


-- Public Methods

---
-- Returns a time in milliseconds in a custom format.
--
-- The following format string configurations are available:
--
-- "-" At the beginning: Cut off every leading text until the first non zero time part or the first non whitespace character
--
-- The following time format specifiers are available:
--
-- %i: Minutes
-- %s: Seconds
-- %v: Milliseconds
-- %T: Total time string time unit (Largest non zero time unit)
--
-- You can add a number of padding zeros between "%" and <format specifier type identifier> to pad
-- the digits by x zeros, e.g. "%02i" will print "4" as "04".
--
-- You can also configure the time unit type with the character after the format specifier type identifier:
--
-- "-": Abbreviated time unit name for that time unit
-- "+": Full time unit name for that time unit
-- "*": Custom time unit name for that time unit
-- <anything else | nothing>: No time unit name is shown
--
-- Numbers after the time unit type configure by how many whitespaces the time unit name will be separated
-- from the time digits.
--
--
-- The given colors list must have the following format:
-- {
--   text = <color>,
--   time = <color>,
--   timeUnit = <color>
-- }
--
-- @tparam int _milliseconds The time in milliseconds
-- @tparam string _format The format for the time
-- @tparam string[] _colors The time colors
--
-- @treturn string The formatted time string
--
function TimeFormatter:generateTimeString(_milliseconds, _format, _colors)

  self:parseMilliseconds(_milliseconds)

  local timeString = _format

  -- Parse the leadingZeroTimePartTrimmingMode config
  if (timeString:find("^%-") == 1) then
    timeString = timeString:sub(2)
    self.leadingZeroTimePartTrimmingMode = self.LEADING_ZERO_TIME_PART_TRIMMING_UNTIL_FIRST_NON_WHITESPACE
  else
    self.leadingZeroTimePartTrimmingMode = self.LEADING_ZERO_TIME_PART_TRIMMING_NONE
  end

  -- Parse and replace all format specifiers
  self.nonZeroTimePartFound = false
  timeString = timeString:gsub(
    "%%(%d*)([isvT])([-+*]?)(%d*)",
    function (...)
      return self:generateFormatSpecifierReplaceText(_colors, ...)
    end
  )

  -- Remove leading whitespace
  timeString = timeString:gsub("^ *", "")

  -- Prepend the default text color
  timeString = _colors["text"] .. timeString

  return timeString

end


-- Private Methods

---
-- Converts a time in milliseconds to minutes, seconds and milliseconds and saves the result in the
-- class attributes "minutes", "seconds" and "milliseconds".
--
-- @tparam int _totalMilliseconds The time in milliseconds
--
function TimeFormatter:parseMilliseconds(_totalMilliseconds)

  local milliseconds = math.fmod(_totalMilliseconds, 1000)

  local totalSeconds = (_totalMilliseconds - milliseconds) / 1000
  local seconds = math.fmod(totalSeconds, 60)

  local minutes = (totalSeconds - seconds) / 60

  self.milliseconds = milliseconds
  self.seconds = seconds
  self.minutes = minutes

end

---
-- Returns the replacement string for a format specifier.
--
-- @tparam string[] _colors The colors to use to colorize the time string
-- @tparam string _formatSpecifierPadding The configured format specifier padding (e.g. "02")
-- @tparam string _formatSpecifierId The format specifier id ("i", "s", "v" or "T")
-- @tparam string _timeUnitType The time unit type ("+", "-", "*")
-- @tparam string _timeUnitNamePadding The time unit name padding (e.g. "04")
--
-- @treturn string The replacement string
--
function TimeFormatter:generateFormatSpecifierReplaceText(_colors, _formatSpecifierPadding, _formatSpecifierId, _timeUnitType, _timeUnitNamePadding)

  local formatSpecifierValue = self:getFormatSpecifierValue(_formatSpecifierId)
  if (formatSpecifierValue == nil) then
    return ""
  end

  if (formatSpecifierValue > 0) then
    self.nonZeroTimePartFound = true
  end

  if (self.leadingZeroTimePartTrimmingMode == self.LEADING_ZERO_TIME_PART_TRIMMING_UNTIL_FIRST_NON_WHITESPACE) then
    if (formatSpecifierValue == 0 and not self.nonZeroTimePartFound) then
      return ""
    end
  end

  local formatSpecifierPadding = tonumber(_formatSpecifierPadding) or 0
  local timeUnitNamePadding = tonumber(_timeUnitNamePadding) or 0

  return string.format(
    _colors["time"] .. "%0" .. formatSpecifierPadding .. "d" .. _colors["timeUnit"] .. "% " .. timeUnitNamePadding .. "s" .. _colors["text"],
    formatSpecifierValue,
    self:getTimeUnitName(_formatSpecifierId, _timeUnitType)
  )

end

---
-- Returns the value for a specific format specifier.
--
-- @tparam string _formatSpecifierId The format specifier id
--
-- @treturn int|nil The format specifier value or nil if the format specifier id is invalid
--
function TimeFormatter:getFormatSpecifierValue(_formatSpecifierId)

  local formatSpecifierValue = nil

  if (_formatSpecifierId == "i") then
    formatSpecifierValue = self.minutes
  elseif (_formatSpecifierId == "s") then
    formatSpecifierValue = self.seconds
  elseif (_formatSpecifierId == "v") then
    formatSpecifierValue = self.milliseconds
  end

  return formatSpecifierValue

end

---
-- Returns the time unit name for a given time unit type.
--
-- @tparam string _formatSpecifierId The format specifier ID
-- @tparam string _timeUnitTypeId The time unit type ID
--
-- @treturn string The time unit name
--
function TimeFormatter:getTimeUnitName(_formatSpecifierId, _timeUnitTypeId)

  local timeUnitName = ""
  if (_formatSpecifierId == "i") then
    -- Minutes
    if (_timeUnitTypeId == "-") then
      timeUnitName = "m"
    elseif (_timeUnitTypeId == "+") then
      timeUnitName = "minutes"
    elseif (_timeUnitTypeId == "*") then
      timeUnitName = self.customTimeUnitNames["minutes"] or ""
    end

  elseif (_formatSpecifierId == "s") then
    -- Seconds
    if (_timeUnitTypeId == "-") then
      timeUnitName = "s"
    elseif (_timeUnitTypeId == "+") then
      timeUnitName = "seconds"
    elseif (_timeUnitTypeId == "*") then
      timeUnitName = self.customTimeUnitNames["seconds"] or ""
    end

  elseif (_formatSpecifierId == "v") then
    -- Milliseconds
    if (_timeUnitTypeId == "-") then
      timeUnitName = "ms"
    elseif (_timeUnitTypeId == "+") then
      timeUnitName = "milliseconds"
    elseif (_timeUnitTypeId == "*") then
      timeUnitName = self.customTimeUnitNames["milliseconds"] or ""
    end

  elseif (_formatSpecifierId == "T") then
    -- Largest non zero time unit
    local largestTimeUnit
    if (self.minutes > 0) then
      largestTimeUnit = "i"
    elseif (self.seconds > 0) then
      largestTimeUnit = "s"
    else
      largestTimeUnit = "v"
    end

    timeUnitName = self:getTimeUnitName(largestTimeUnit, _timeUnitTypeId)
  end

  return timeUnitName

end


return TimeFormatter
