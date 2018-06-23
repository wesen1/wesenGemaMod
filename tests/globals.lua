---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

-- Mocks for the global functions that the AssaultCube lua server provides

-- Weapon id constants
GUN_ASSAULT = 6;
GUN_SUBGUN = 4;
GUN_CARBINE = 2;
GUN_SNIPER = 5;
GUN_SHOTGUN = 3;
GUN_KNIFE = 0;
GUN_PISTOL = 1;

-- Team id constants
TEAM_CLA = 0;
TEAM_RVSF = 1;

-- Config methods
cfg = {};

function cfg.getvalue(_index)
  return _index;
end

function cfg.totable()
  return {};
end
