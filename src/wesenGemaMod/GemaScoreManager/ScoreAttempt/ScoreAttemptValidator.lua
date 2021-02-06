---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ClassLoader = require "Util.ClassLoader"
local Object = require "classic"

---
-- Checks if given ScoreAttempt's are valid.
--
-- @type ScoreAttemptValidator
--
local ScoreAttemptValidator = Object:extend()

---
-- The checks that will be executed to validate given ScoreAttempt's
--
-- @tfield ScoreAttemptValidationCheck[] checks
--
ScoreAttemptValidator.checks = nil


---
-- ScoreAttemptValidator constructor.
--
function ScoreAttemptValidator:new()
  self.checks = self:loadValidationChecks()
end


-- Public Methods

---
-- Initializes this ScoreAttemptValidator.
--
function ScoreAttemptValidator:initialize()
  for _, check in ipairs(self.checks) do
    check:initialize()
  end
end

---
-- Terminates this ScoreAttemptValidator.
--
function ScoreAttemptValidator:terminate()
  for _, check in ipairs(self.checks) do
    check:terminate()
  end
end

---
-- Returns the reason why a given ScoreAttempt is not valid.
-- Will return nil if the ScoreAttempt is valid.
--
-- @tparam int _cn The client number of the player to which the ScoreAttempt belongs
-- @tparam ScoreAttempt _scoreAttempt The ScoreAttempt to validate
--
-- @treturn string|nil The reason why the ScoreAttempt is not valid
--
function ScoreAttemptValidator:getScoreAttemptNotValidReason(_cn, _scoreAttempt)

  for _, check in ipairs(self.checks) do
    if (not check:isScoreAttemptValid(_cn, _scoreAttempt)) then
      return check:getErrorMessage()
    end
  end

end


-- Private Methods

---
-- Loads and instantiates all ScoreAttemptValidationCheck's.
--
-- @treturn ScoreAttemptValidationCheck[] The loaded ScoreAttemptValidationCheck's
--
function ScoreAttemptValidator:loadValidationChecks()

  local validationCheckClasses = ClassLoader.loadClasses(
    "lua/scripts/wesenGemaMod/GemaScoreManager/ScoreAttempt/Validator",
    ".*Check.lua",
    { "ScoreAttemptValidationCheck" }
  )

  local validationCheckInstances = {}
  for _, validationCheckClass in ipairs(validationCheckClasses) do
    table.insert(validationCheckInstances, validationCheckClass())
  end

  return validationCheckInstances

end


return ScoreAttemptValidator
