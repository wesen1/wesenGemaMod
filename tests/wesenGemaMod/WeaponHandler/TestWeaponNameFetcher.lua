---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TestCase = require("TestFrameWork/TestCase");
local WeaponNameFetcher = require("WeaponHandler/WeaponNameFetcher");

---
-- Checks whether the WeaponNameFetcher works as expected.
--
-- @type TestWeaponNameFetcher
--
local TestWeaponNameFetcher = setmetatable({}, {__index = TestCase});


---
-- Checks whether the constructor works as expected.
--
function TestWeaponNameFetcher:testCanBeConstructed()

  local weaponNameFetcher = WeaponNameFetcher();
  self.assertInstanceOf(weaponNameFetcher, WeaponNameFetcher);

  local weaponNames = weaponNameFetcher.weaponNames;

  self.assertEquals(weaponNames[GUN_ASSAULT], "Assault Rifle");
  self.assertEquals(weaponNames[GUN_SUBGUN], "Submachine Gun");
  self.assertEquals(weaponNames[GUN_CARBINE], "Carbine");
  self.assertEquals(weaponNames[GUN_SNIPER], "Sniper Rifle");
  self.assertEquals(weaponNames[GUN_SHOTGUN], "Shotgun");
  self.assertEquals(weaponNames[GUN_KNIFE], "Knife Only");
  self.assertEquals(weaponNames[GUN_PISTOL], "Pistol Only");

end

---
-- Checks whether the weapon names are returned as expected.
--
function TestWeaponNameFetcher:testCanFetchWeaponName()

  local weaponNameFetcher = WeaponNameFetcher();

  -- Valid weapon ids
  self.assertEquals(weaponNameFetcher:getWeaponName(GUN_ASSAULT), "Assault Rifle");
  self.assertEquals(weaponNameFetcher:getWeaponName(GUN_SUBGUN), "Submachine Gun");
  self.assertEquals(weaponNameFetcher:getWeaponName(GUN_CARBINE), "Carbine");
  self.assertEquals(weaponNameFetcher:getWeaponName(GUN_SNIPER), "Sniper Rifle");
  self.assertEquals(weaponNameFetcher:getWeaponName(GUN_SHOTGUN), "Shotgun");
  self.assertEquals(weaponNameFetcher:getWeaponName(GUN_KNIFE), "Knife Only");
  self.assertEquals(weaponNameFetcher:getWeaponName(GUN_PISTOL), "Pistol Only");

  -- Invalid weapon ids
  for i = 7, 17, 1 do
    self.assertEquals(weaponNameFetcher:getWeaponName(i), "Unknown Weapon ID (" .. i .. ")");
  end

  for i = -10, -1, 1 do
    self.assertEquals(weaponNameFetcher:getWeaponName(i), "Unknown Weapon ID (" .. i .. ")");
  end

end


return TestWeaponNameFetcher;
