---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"

---
-- Exception for the case that information about a finished ScoreAttempt should be fetched from an
-- unfinished ScoreAttempt.
--
-- @type ScoreAttemptNotFinishedException
--
local ScoreAttemptNotFinishedException = Exception:extend()

---
-- The name of the attribute that caused the exception
--
-- @tfield string fetchedAttributeName
--
ScoreAttemptNotFinishedException.fetchedAttributeName = nil


---
-- ScoreAttemptNotFinishedException constructor.
--
-- @tparam string _fetchedAttributeName The name of the attribute that was attempted to be fetched
--
function ScoreAttemptNotFinishedException:new(_fetchedAttributeName)
  self.fetchedAttributeName = _fetchedAttributeName
end


-- Getters and Setters

---
-- Returns the name of the attribute that caused the exception.
--
-- @treturn string The name of the attribute that was attempted to be fetched
--
function ScoreAttemptNotFinishedException:getFetchedAttributeName()
  return self.fetchedAttributeName
end


-- Public Methods

---
-- Returns this Exception's message as a string.
--
-- @treturn string The Exception message as a string
--
function ScoreAttemptNotFinishedException:getMessage()
  return string.format(
    "Could not fetch attribute \"%s\" from ScoreAttempt: ScoreAttempt is not finished yet",
    self.fetchedAttributeName
  )
end


return ScoreAttemptNotFinishedException
