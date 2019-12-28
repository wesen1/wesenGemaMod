---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");

---
-- Class that handles player role changes.
-- PlayerRoleChangeHandler inherits from BaseEventHandler
--
-- @type PlayerRoleChangeHandler
--
local PlayerRoleChangeHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- PlayerRoleChangeHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn PlayerRoleChangeHandler The PlayerRoleChangeHandler instance
--
function PlayerRoleChangeHandler:__construct(_parentGemaMode)

  local instance = BaseEventHandler(_parentGemaMode, "onPlayerRoleChange");
  setmetatable(instance, {__index = PlayerRoleChangeHandler});

  return instance;

end

getmetatable(PlayerRoleChangeHandler).__call = PlayerRoleChangeHandler.__construct;


-- Class Methods

---
-- Event handler which is called when a player role changes (admin login/logout).
-- Sets the player level according to the role change
--
-- @tparam int _cn The client number of the player whose role changed
-- @tparam int _newRole The new role
--
function PlayerRoleChangeHandler:handleEvent(_cn, _newRole)

  if (self.parentGemaMode:getIsActive()) then

    local player = self:getPlayerByCn(_cn)

    if (_newRole == CR_ADMIN) then
      player:setLevel(1);
    elseif (_newRole == CR_DEFAULT) then
      player:setLevel(0);
    end

  end

end


return PlayerRoleChangeHandler;
