---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Base class for ScoreAttempt validation check's.
-- A validation check should monitor a single aspect (for example "Did the player steal the flag?" or
-- "Does the current map still exist on the server?").
--
-- @type ScoreAttemptValidationCheck
--
local ScoreAttemptValidationCheck = Object:extend()


-- Public Methods

---
-- Initializes this ScoreAttemptValidationCheck.
--
function ScoreAttemptValidationCheck:initialize()
end

---
-- Terminates this ScoreAttemptValidationCheck.
--
function ScoreAttemptValidationCheck:terminate()
end

---
-- Checks whether a given ScoreAttempt is valid.
-- This should only evaluate the single aspect that is monitored by this ScoreAttemptValidationCheck.
--
-- @tparam int _cn The client number of the player to which the ScoreAttempt belongs
-- @tparam ScoreAttempt _scoreAttempt The ScoreAttempt to validate
--
-- @treturn bool True if the ScoreAttempt is valid, false otherwise
--
function ScoreAttemptValidationCheck:isScoreAttemptValid(_cn, _scoreAttempt)
end

---
-- Returns the error message that explains why a ScoreAttempt was not valid that
-- did not meet this check's conditions.
-- This message will be shown to the players.
--
-- @treturn string The error message
--
function ScoreAttemptValidationCheck:getErrorMessage()
end


return ScoreAttemptValidationCheck
