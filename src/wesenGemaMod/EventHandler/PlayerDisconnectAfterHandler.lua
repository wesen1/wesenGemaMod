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
-- Event handler which is called after a player disconnected.
--
-- @tparam int _cn The client number of the player who disconnected
-- @tparam int _reason The disconnect reason
--
function PlayerDisconnectAfterHandler:handleEvent(_cn, _reason)

  -- The player is removed from the list of players after he fully disconnected because a flag action
  -- event will be fired when he holds the flag before disconnecting
  self.parentGemaMode:getPlayerList():removePlayer(_cn);

end


return PlayerDisconnectAfterHandler;
