---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");

---
-- Class that handles player disconnects.
-- PlayerDisconnectAfterHandler inherits from BaseEventHandler
--
-- @type PlayerDisconnectAfterHandler
--
local PlayerDisconnectAfterHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- PlayerDisconnectAfterHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn PlayerDisconnectAfterHandler The PlayerDisconnectAfterHandler instance
--
function PlayerDisconnectAfterHandler:__construct(_parentGemaMode)

  local instance = BaseEventHandler(_parentGemaMode);
  setmetatable(instance, {__index = PlayerDisconnectAfterHandler});

  return instance;

end

getmetatable(PlayerDisconnectAfterHandler).__call = PlayerDisconnectAfterHandler.__construct;


-- Class Methods

---
-- Event handler which is called when a player disconnects.
-- Unsets the player object of the cn and prints an error message in case of a banned player trying to connect
--
-- @tparam int _cn The client number of the player who disconnected
-- @tparam int _reason The disconnect reason
--
function PlayerDisconnectAfterHandler:onPlayerDisconnectAfter(_cn, _reason)

  if (_reason == DISC_BANREFUSE) then
    local infoMessage = string.format("%s could not connect [banned]", getname(_cn));
    self.output:printInfo(infoMessage);
  end

  -- The player is removed from the list of players after he fully disconnected because a flag action
  -- event will be fired when he holds the flag before disconnecting
  self.parentGemaMode:getPlayerList():removePlayer(_cn);

end


return PlayerDisconnectAfterHandler;
