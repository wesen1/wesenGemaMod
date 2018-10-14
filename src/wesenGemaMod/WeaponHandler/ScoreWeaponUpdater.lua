---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Updates the score weapon of a player (if necessary).
--
-- @type ScoreWeaponUpdater
--
local ScoreWeaponUpdater = setmetatable({}, {});


---
-- ScoreWeaponUpdater constructor.
--
-- @treturn ScoreWeaponUpdater The ScoreWeaponUpdater instance
--
function ScoreWeaponUpdater:__construct()

  local instance = setmetatable({}, { __index = ScoreWeaponUpdater });

  return instance;

end

getmetatable(ScoreWeaponUpdater).__call = ScoreWeaponUpdater.__construct;


-- Public Methods

---
-- Updates the score weapon for a score attempt (if necessary).
--
-- @tparam PlayerScoreAttempt _scoreAttempt The players score attempt
-- @tparam int _weaponUsed The id of the weapon that the player used
--
function ScoreWeaponUpdater:updateScoreWeapon(_scoreAttempt, _weaponUsed)

  if (not _scoreAttempt:isFinished()) then

    local updatedScoreWeaponId = self:getUpdatedScoreWeaponId(_scoreAttempt, _weaponUsed);  
    if (updatedScoreWeaponId) then
      _scoreAttempt:setWeaponId(updatedScoreWeaponId);
    end

  end

end

---
-- Updates the score weapon if it is necessary.
--
-- @tparam PlayerScoreAttempt _scoreAttempt The players score attempt
-- @tparam int _weaponUsed The id of the weapon that the player used
--
-- @treturn int|nil The updated score weapon or nil if the score weapon doesn't need to be updated
--
function ScoreWeaponUpdater:getUpdatedScoreWeaponId(_scoreAttempt, _weaponUsed)

  local updatedScoreWeaponId = nil;

  if (_weaponUsed ~= GUN_KNIFE and _weaponUsed ~= GUN_GRENADE) then

    local weaponUsedIsPistol = (_weaponUsed == GUN_PISTOL or _weaponUsed == GUN_AKIMBO);

    if (_scoreAttempt:getWeaponId() == GUN_KNIFE) then

      if (weaponUsedIsPistol) then
        updatedScoreWeaponId = GUN_PISTOL;
      else
        updatedScoreWeaponId = _weaponUsed;
      end

    elseif (_scoreAttempt:getWeaponId() == GUN_PISTOL and not weaponUsedIsPistol) then
      updatedScoreWeaponId = _weaponUsed;
    end

  end

  return updatedScoreWeaponId;

end


return ScoreWeaponUpdater;
