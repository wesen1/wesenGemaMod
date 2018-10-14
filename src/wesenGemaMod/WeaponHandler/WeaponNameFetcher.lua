---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Converts weapon ids to weapon names.
--
-- @type WeaponNameFetcher
--
local WeaponNameFetcher = setmetatable({}, {});

---
-- The list of weapon names in the format [weaponId] = weaponName
--
-- @tfield string[] weaponNames
--
WeaponNameFetcher.weaponNames = nil;


---
-- WeaponNameFetcher constructor.
--
-- @treturn WeaponNameFetcher The WeaponNameFetcher instance
--
function WeaponNameFetcher:__construct()

  local instance = setmetatable({}, {__index = WeaponNameFetcher});

  --@todo: Make these constants? (Same in MapNameChecker)
  instance.weaponNames = {
    [GUN_ASSAULT] = "Assault Rifle",
    [GUN_SUBGUN] = "Submachine Gun",
    [GUN_CARBINE] = "Carbine",
    [GUN_SNIPER] = "Sniper Rifle",
    [GUN_SHOTGUN] = "Shotgun",
    [GUN_KNIFE] = "Knife Only",
    [GUN_PISTOL] = "Pistol Only"
  }
  
  return instance;

end

getmetatable(WeaponNameFetcher).__call = WeaponNameFetcher.__construct;

---
-- Converts weapon ids to weapon names.
--
-- @tparam int _weaponId The weapon id
--
-- @treturn string The weapon name
--
function WeaponNameFetcher:getWeaponName(_weaponId)

  local weaponName = self.weaponNames[_weaponId];

  if (weaponName ~= nil) then
    return weaponName;
  else
    return "Unknown Weapon ID (" .. _weaponId .. ")";
  end

end


return WeaponNameFetcher;
