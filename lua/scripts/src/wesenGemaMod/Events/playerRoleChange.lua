---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

---
-- Event handler which is called when a player role changes (admin login/logout).
-- Sets the player level according to the role change
--
-- @param _cn (int) Client number of the player
-- @param _newRole (int) The new role
--
function onPlayerRoleChange (_cn, _newRole)

  if (_newRole == CR_ADMIN) then
    players[_cn]:setLevel(1);
  elseif (_newRole == CR_DEFAULT) then
    players[_cn]:setLevel(0);
  end

end