---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Class that handles player role changes.
--
-- @type PlayerRoleChangeHandler
--
local PlayerRoleChangeHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
--
-- @tfield GemaMod parentGemaMod
--
PlayerRoleChangeHandler.parentGemaMod = "";


---
-- PlayerRoleChangeHandler constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn PlayerRoleChangeHandler The PlayerRoleChangeHandler instance
--
function PlayerRoleChangeHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerRoleChangeHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;

end


-- Getters and setters

---
-- Returns the parent gema mod.
--
-- @treturn GemaMod The parent gema mod
--
function PlayerRoleChangeHandler:getParentGemaMod()
  return self.parentGemaMod;
end

---
-- Sets the parent gema mod.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
function PlayerRoleChangeHandler:setParentGemaMod(_parentGemaMod)
  self.parentGemaMod = _parentGemaMod;
end


-- Class Methods

---
-- Event handler which is called when a player role changes (admin login/logout).
-- Sets the player level according to the role change
--
-- @tparam int _cn The client number of the player whose role changed
-- @tparam int _newRole The new role
--
function PlayerRoleChangeHandler:onPlayerRoleChange (_cn, _newRole)

  local player = self.parentGemaMod:getPlayers()[_cn];

  if (_newRole == CR_ADMIN) then
    player:setLevel(1);
  elseif (_newRole == CR_DEFAULT) then
    player:setLevel(0);
  end

end


return PlayerRoleChangeHandler;
