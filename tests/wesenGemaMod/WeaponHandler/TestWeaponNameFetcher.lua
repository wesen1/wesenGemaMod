---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local luaunit = require("luaunit-custom");
local WeaponNameFetcher = require("WeaponHandler/WeaponNameFetcher");

---
-- Checks whether the WeaponNameFetcher works as expected.
--
-- @type TestWeaponNameFetcher
--
local TestWeaponNameFetcher = {};


---
-- Checks whether the constructor works as expected.
--
function TestWeaponNameFetcher:testCanBeConstructed()

  local weaponNameFetcher = WeaponNameFetcher();
  luaunit.assertInstanceOf(weaponNameFetcher, WeaponNameFetcher);

  local weaponNames = weaponNameFetcher.weaponNames;

  luaunit.assertEquals(weaponNames[GUN_ASSAULT], "Assault Rifle");
  luaunit.assertEquals(weaponNames[GUN_SUBGUN], "Submachine Gun");
  luaunit.assertEquals(weaponNames[GUN_CARBINE], "Carbine");
  luaunit.assertEquals(weaponNames[GUN_SNIPER], "Sniper Rifle");
  luaunit.assertEquals(weaponNames[GUN_SHOTGUN], "Shotgun");
  luaunit.assertEquals(weaponNames[GUN_KNIFE], "Knife Only");
  luaunit.assertEquals(weaponNames[GUN_PISTOL], "Pistol Only");

end

---
-- Checks whether the weapon names are returned as expected.
--
function TestWeaponNameFetcher:testCanFetchWeaponName()

  local weaponNameFetcher = WeaponNameFetcher();

  -- Valid weapon ids
  luaunit.assertEquals(weaponNameFetcher:getWeaponName(GUN_ASSAULT), "Assault Rifle");
  luaunit.assertEquals(weaponNameFetcher:getWeaponName(GUN_SUBGUN), "Submachine Gun");
  luaunit.assertEquals(weaponNameFetcher:getWeaponName(GUN_CARBINE), "Carbine");
  luaunit.assertEquals(weaponNameFetcher:getWeaponName(GUN_SNIPER), "Sniper Rifle");
  luaunit.assertEquals(weaponNameFetcher:getWeaponName(GUN_SHOTGUN), "Shotgun");
  luaunit.assertEquals(weaponNameFetcher:getWeaponName(GUN_KNIFE), "Knife Only");
  luaunit.assertEquals(weaponNameFetcher:getWeaponName(GUN_PISTOL), "Pistol Only");

  -- Invalid weapon ids
  for i = 7, 17, 1 do
    luaunit.assertEquals(weaponNameFetcher:getWeaponName(i), "Unknown Weapon ID (" .. i .. ")");
  end

  for i = -10, -1, 1 do
    luaunit.assertEquals(weaponNameFetcher:getWeaponName(i), "Unknown Weapon ID (" .. i .. ")");
  end

end


return TestWeaponNameFetcher;
