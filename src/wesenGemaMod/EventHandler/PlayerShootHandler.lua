---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");
local ScoreWeaponUpdater = require("WeaponHandler/ScoreWeaponUpdater");

---
-- Class that handles player shots.
-- PlayerShootHandler inherits from BaseEventHandler
--
-- @type PlayerShootHandler
--
local PlayerShootHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- The score weapon updater
--
-- @tfield ScoreWeaponUpdater scoreWeaponUpdater
--
PlayerShootHandler.scoreWeaponUpdater = nil;


---
-- PlayerShootHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn PlayerShootHandler The PlayerShootHandler instance
--
function PlayerShootHandler:__construct(_parentGemaMode)

  local instance = BaseEventHandler(_parentGemaMode);
  setmetatable(instance, {__index = PlayerShootHandler});

  instance.scoreWeaponUpdater = ScoreWeaponUpdater();

  return instance;

end

getmetatable(PlayerShootHandler).__call = PlayerShootHandler.__construct;


-- Class Methods

---
-- Event handler that is called when a player shoots.
--
-- @tparam int _player The player who shot
-- @tparam int _weapon The weapon with which the player shot
--
function PlayerShootHandler:onPlayerShoot(_player, _weapon)

  if (self.parentGemaMode:getIsActive()) then
    self.scoreWeaponUpdater:updateScoreWeapon(_player:getScoreAttempt(), _weapon);
  end

end


return PlayerShootHandler;
