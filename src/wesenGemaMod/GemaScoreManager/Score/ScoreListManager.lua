---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Manages updating a single ScoreList.
--
-- @type ScoreListManager
--
local ScoreListManager = Object:extend()

---
-- The ScoreList that is managed by this ScoreListManager
--
-- @tfield ScoreList scoreList
--
ScoreListManager.scoreList = nil


---
-- ScoreListManager constructor.
--
-- @tparam ScoreList _scoreList The ScoreList to manage
--
function ScoreListManager:new(_scoreList)
  self.scoreList = _scoreList
end


-- Getters and Setters

---
-- Returns the ScoreList that is managed by this ScoreListManager.
--
-- @treturn ScoreList The ScoreList
--
function ScoreListManager:getScoreList()
  return self.scoreList
end


-- Public Methods

---
-- Initializes this ScoreListManager.
--
function ScoreListManager:initialize()
end

---
-- Terminates this ScoreListManager.
--
function ScoreListManager:terminate()
end


return ScoreListManager
