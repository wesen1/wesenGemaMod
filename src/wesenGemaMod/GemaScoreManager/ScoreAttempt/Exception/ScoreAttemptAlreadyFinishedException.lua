---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"

---
-- Exception for the case that a ScoreAttempt should be modified while it already is finished.
--
-- @type ScoreAttemptAlreadyFinishedException
--
local ScoreAttemptAlreadyFinishedException = Exception:extend()

---
-- The name of the attribute whose attempted modification caused the exception
--
-- @tfield string modifiedAttributeName
--
ScoreAttemptAlreadyFinishedException.modifiedAttributeName = nil


---
-- ScoreAttemptAlreadyFinishedException constructor.
--
-- @tparam string _modifiedAttributeName The name of the attribute whose modification was attempted
--
function ScoreAttemptAlreadyFinishedException:new(_modifiedAttributeName)
  self.modifiedAttributeName = _modifiedAttributeName
end


-- Getters and Setters

---
-- Returns the name of the attribute whose attempted modification caused the exception.
--
-- @treturn string The name of the attribute whose modification was attempted
--
function ScoreAttemptAlreadyFinishedException:getModifiedAttributeName()
  return self.modifiedAttributeName
end


-- Public Methods

---
-- Returns this Exception's message as a string.
--
-- @treturn string The Exception message as a string
--
function ScoreAttemptAlreadyFinishedException:getMessage()
  return string.format(
    "Could not modify ScoreAttempt attribute \"%s\": ScoreAttempt is already finished",
    self.modifiedAttributeName
  )
end


return ScoreAttemptAlreadyFinishedException
