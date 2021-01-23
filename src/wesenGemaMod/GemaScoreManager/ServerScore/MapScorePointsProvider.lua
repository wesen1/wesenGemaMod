---
-- @author wesen
-- @copyright 2020-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Provides methods to fetch the numbers of ServerScore points for given MapScore's.
--
-- The default implementation returns the following points based on the rank of the MapScore:
-- 1st: 10
-- 2nd: 3
-- 3rd: 2
-- everything else: 1
--
-- @type MapScorePointsProvider
--
local MapScorePointsProvider = Object:extend()


-- Public Methods

---
-- Returns the ServerScore points for a given MapScore.
--
-- @tparam MapScore _mapScore The MapScore for which to return a corresponding amount of ServerScore points
--
-- @treturn int The ServerScore points for the given MapScore
--
function MapScorePointsProvider:getPointsForMapScore(_mapScore)

  if (_mapScore:getRank() == 1) then
    return 10
  elseif (_mapScore:getRank() == 2) then
    return 3
  elseif (_mapScore:getRank() == 3) then
    return 2
  else
    return 1
  end

end


return MapScorePointsProvider
