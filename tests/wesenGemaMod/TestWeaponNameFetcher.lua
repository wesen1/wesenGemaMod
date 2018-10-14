---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local luaunit = require("luaunit");
local WeaponNameFetcher = require("WeaponHandler/WeaponNameFetcher");

---
-- Checks whether the WeaponNameFetcher works as expected.
--
TestWeaponNameFetcher = {};

---
-- Checks whether the weapon names are returned as expected.
--
function TestWeaponNameFetcher:testCanFetchWeaponName()

  -- Valid weapon ids
  luaunit.assertEquals(WeaponNameFetcher:getWeaponName(GUN_ASSAULT), "Assault Rifle");
  luaunit.assertEquals(WeaponNameFetcher:getWeaponName(GUN_SUBGUN), "Submachine Gun");
  luaunit.assertEquals(WeaponNameFetcher:getWeaponName(GUN_CARBINE), "Carbine");
  luaunit.assertEquals(WeaponNameFetcher:getWeaponName(GUN_SNIPER), "Sniper Rifle");
  luaunit.assertEquals(WeaponNameFetcher:getWeaponName(GUN_SHOTGUN), "Shotgun");
  luaunit.assertEquals(WeaponNameFetcher:getWeaponName(GUN_KNIFE), "Knife Only");
  luaunit.assertEquals(WeaponNameFetcher:getWeaponName(GUN_PISTOL), "Pistol Only");

  -- Invalid weapon ids
  for i = 7, 17, 1 do
    luaunit.assertEquals(WeaponNameFetcher:getWeaponName(i), "Unknown Weapon ID (" .. i .. ")");
  end

  for i = -10, -1, 1 do
    luaunit.assertEquals(WeaponNameFetcher:getWeaponName(i), "Unknown Weapon ID (" .. i .. ")");
  end

end
