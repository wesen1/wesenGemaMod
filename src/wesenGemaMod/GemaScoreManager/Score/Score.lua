---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Contains the score of a single Player.
--
-- @type Score
--
local Score = Object:extend()

---
-- The Player to which this Score belongs
--
-- @tfield Player player
--
Score.player = nil

---
-- The rank of this Score in the parent ScoreList
--
-- @tfield int rank
--
Score.rank = nil


---
-- Score constructor.
--
-- @tparam Player _player The Player to which the Score belongs
-- @tparam int _rank The initial rank (optional)
--
function Score:new(_player, _rank)
  self.player = _player
  self.rank = _rank
end


-- Getters and Setters

---
-- Returns the Player to which this Score belongs.
--
-- @treturn Player The Player to which this Score belongs
--
function Score:getPlayer()
  return self.player
end

---
-- Returns the rank of this Score in the parent ScoreList.
--
-- @treturn int The rank
--
function Score:getRank()
  return self.rank
end

---
-- Sets the rank of this Score.
--
-- @tparam int _rank The rank to set
--
function Score:setRank(_rank)
  self.rank = _rank
end


return Score
