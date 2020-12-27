---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Provides methods to fetch the numbers of ServerScore points for given MapTop ranks.
-- The default implementation returns the following points:
-- 1st: 10
-- 2nd: 3
-- 3rd: 2
-- everything else: 1
--
-- @type MapRankPointsProvider
--
local MapRankPointsProvider = Object:extend()


-- Public Methods

---
-- Returns the ServerScore points for a given MapTop rank.
--
-- @tparam int _mapRank The MapTop rank for which to return a corresponding amount of ServerScore points
--
-- @treturn int The ServerScore points for the given MapTop rank
--
function MapRankPointsProvider:getPointsForMapRank(_mapRank)

  if (_mapRank == 1) then
    return 10
  elseif (_mapRank == 2) then
    return 3
  elseif (_mapRank == 3) then
    return 2
  else
    return 1
  end

end


return MapRankPointsProvider
