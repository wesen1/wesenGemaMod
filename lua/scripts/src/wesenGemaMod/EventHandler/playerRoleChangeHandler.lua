---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- 

---
-- Class that handles player role changes.
--
local PlayerRoleChangeHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
-- 
-- @param GemaMod parentGemaMod
-- 
PlayerRoleChangeHandler.parentGemaMod = "";


---
-- PlayerRoleChangeHandler constructor.
-- 
-- @param GemaMod _parentGemaMod The parent gema mod
--
function PlayerRoleChangeHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerRoleChangeHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;
  
end

---
-- Event handler which is called when a player role changes (admin login/logout).
-- Sets the player level according to the role change
--
-- @param _cn (int) The client number of the player
-- @param _newRole (int) The new role
--
function PlayerRoleChangeHandler:onPlayerRoleChange (_cn, _newRole)

  if (_newRole == CR_ADMIN) then
    self.parentGemaMod:players()[_cn]:setLevel(1);
  elseif (_newRole == CR_DEFAULT) then
    self.parentGemaMod:players()[_cn]:setLevel(0);
  end

end


return PlayerRoleChangeHandler;
