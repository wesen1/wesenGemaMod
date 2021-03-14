---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Manages multiple ScoreListManager's.
--
-- @type ScoreManager
--
local ScoreManager = Object:extend()

---
-- The ScoreListManager's
--
-- @tfield ScoreListManager scoreListManagers
--
ScoreManager.scoreListManagers = nil

---
-- The ScoreContextProvider that will be used to interpret score contexts
--
-- @tfield ScoreContextProvider scoreContextProvider
--
ScoreManager.scoreContextProvider = nil


---
-- ScoreManager constructor.
--
-- @tparam ScoreContextProvider _scoreContextProvider The ScoreContextProvider to use
-- @tparam string[] _contexts The contexts to create ScoreListManager's for
--
function ScoreManager:new(_scoreContextProvider, _contexts)
  self.scoreContextProvider = _scoreContextProvider
  self.scoreListManagers = {}

  for _, context in ipairs(_contexts) do
    self.scoreListManagers[context] = self:createScoreListManager(context)
  end
end


-- Getters and Setters

---
-- Returns the list of ScoreListManager's.
--
-- @treturn ScoreListManager[] The list of ScoreListManager's
--
function ScoreManager:getScoreListManagers()
  return self.scoreListManagers
end


-- Public Methods

---
-- Initializes this ScoreManager.
--
function ScoreManager:initialize()
  for _, scoreListManager in pairs(self.scoreListManagers) do
    scoreListManager:initialize()
  end
end

---
-- Terminates this ScoreManager.
--
function ScoreManager:terminate()
  for _, scoreListManager in pairs(self.scoreListManagers) do
    scoreListManager:terminate()
  end
end


---
-- Returns the ScoreListManager for a specific context.
--
-- @tparam string _context The context to return the corresponding ScoreListManager for (e.g. weapon ID)
--
-- @treturn ScoreListManager|nil The ScoreListManager for the given context
--
function ScoreManager:getScoreListManager(_context)
  return self.scoreListManagers[_context]
end


-- Protected Methods

---
-- Creates and returns a ScoreListManager.
--
-- @tparam string _context The context to create the ScoreListManager for
--
-- @treturn ScoreListManager The created ScoreListManager
--
function ScoreManager:createScoreListManager(_context)
end


return ScoreManager
