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
local WeaponNameFetcher = {};

---
-- The list of weapon names in the format [weaponId] = weaponName
--
-- @tfield string[] weaponNames
--
WeaponNameFetcher.weaponNames = {};

-- Set the weapon names after initializing the attribute as empty table to avoid LDoc error messages
WeaponNameFetcher.weaponNames = {

  [GUN_ASSAULT] = "Assault Rifle",
  [GUN_SUBGUN] = "Submachine Gun",
  [GUN_CARBINE] = "Carbine",
  [GUN_SNIPER] = "Sniper Rifle",
  [GUN_SHOTGUN] = "Shotgun"

}

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
