---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Class that handles player shots.
--
-- @type PlayerShootHandler
--
local PlayerShootHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
--
-- @tfield GemaMod parentGemaMod
--
PlayerShootHandler.parentGemaMod = "";


---
-- PlayerShootHandler constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn PlayerShootHandler The PlayerShootHandler instance
--
function PlayerShootHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerShootHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;

end


-- Getters and setters

---
-- Returns the parent gema mod.
--
-- @treturn GemaMod The parent gema mod
--
function PlayerShootHandler:getParentGemaMod()
  return self.parentGemaMod;
end

---
-- Sets the parent gema mod.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
function PlayerShootHandler:setParentGemaMod(_parentGemaMod)
  self.parentGemaMod = _parentGemaMod;
end


-- Class Methods

---
-- Event handler that is called when a player shoots.
--
-- @tparam int _cn The client number of the player who shot
-- @tparam int _weapon The weapon with which the player shot
--
function PlayerShootHandler:onPlayerShoot(_cn, _weapon)

  if (self.parentGemaMod:getIsActive()) then

    local player = self.parentGemaMod:getPlayers()[_cn];

    if (_weapon ~= GUN_KNIFE and _weapon ~= GUN_GRENADE) then

      if (player:getWeapon() == GUN_KNIFE) then

        if (self:isWeaponPistol(_weapon)) then
          player:setWeapon(GUN_PISTOL);
        else
          player:setWeapon(getprimary(_cn));
        end

      elseif (player:getWeapon() == GUN_PISTOL and not self:isWeaponPistol(_weapon)) then
        player:setWeapon(getprimary(_cn));
      end

    end

  end

end

---
-- Returns whether a weapon is a pistol.
--
-- @tparam int _weapon The weapon id
--
-- @treturn bool true: The weapon is a pistol
--               false: The weapon is not a pistol
--
function PlayerShootHandler:isWeaponPistol(_weapon)

  if (_weapon == GUN_PISTOL or _weapon == GUN_AKIMBO) then
    return true;
  else
    return false;
  end

end


return PlayerShootHandler;
