---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"
local ScoreContextProvider = require "GemaScoreManager.ScoreContextProvider"
local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"

---
-- Util class that converts command argument score contexts to the corresponding ScoreContextProvider constants.
-- Will throw TemplateException's if the score context can not be resolved.
--
-- @type ScoreContextResolver
--
local ScoreContextResolver = Object:extend()

---
-- The GemaScoreManager that will be used to resolve score context aliases to MapTop's and ServerTop's
--
-- @tfield GemaScoreManager gemaScoreManager
--
ScoreContextResolver.gemaScoreManager = nil


---
-- ScoreContextResolver constructor.
--
-- @tparam GemaScoreManager gemaScoreManager The GemaScoreManager to use to resolve score context aliases
--
function ScoreContextResolver:new(_gemaScoreManager)
  self.gemaScoreManager = _gemaScoreManager
end


-- Public Methods

---
-- Returns the MapTop for a given command input score context.
--
-- @tparam string|nil _inputScoreContext The command input score context
--
-- @treturn int The score context ID
-- @treturn MapTop The MapTop for the given score context
--
-- @raise TemplateException The Exception when no MapTop is available for the given score context
--
function ScoreContextResolver:getMapTopForScoreContext(_inputScoreContext)

  local scoreContext = self:resolveScoreContext(_inputScoreContext)

  local mapTop = self.gemaScoreManager:getMapTopManager():getMapTop(scoreContext)
  if (mapTop == nil) then
    error(TemplateException(
      "GemaScoreManager/CommandUtil/ScoreContextResolver/Exceptions/NoMapTopForContextAvailable",
      {
        scoreContextProvider = self.gemaScoreManager:getScoreContextProvider(),
        scoreContext = scoreContext
      }
    ))
  else
    return scoreContext, mapTop
  end

end


-- Private Methods

---
-- Returns the corresponding score context constant for a given command input score context.
--
-- @tparam string|nil _inputScoreContext The command input score context
--
-- @treturn int The corresponding score context constant for the given command input score context
--
-- @raise TemplateException The Exception when no score context could be found for the given command input score context
--
function ScoreContextResolver:resolveScoreContext(_inputScoreContext)

  if (_inputScoreContext == nil) then
    -- Default to "main" if no context is given
    return ScoreContextProvider.CONTEXT_MAIN

  else

    local scoreContext = self.gemaScoreManager:getScoreContextProvider():getScoreContextByAlias(_inputScoreContext:lower())
    if (scoreContext == nil) then
      error(TemplateException(
        "GemaScoreManager/CommandUtil/ScoreContextResolver/Exceptions/InvalidScoreContext",
        { invalidScoreContext = _inputScoreContext }
      ))
    else
      return scoreContext
    end

  end

end


return ScoreContextResolver
