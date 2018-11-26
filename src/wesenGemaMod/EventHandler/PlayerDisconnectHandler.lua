---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");
local TextTemplate = require("Output/Template/TextTemplate");

---
-- Class that handles player disconnects.
-- PlayerDisconnectHandler inherits from BaseEventHandler
--
-- @type PlayerDisconnectHandler
--
local PlayerDisconnectHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- PlayerDisconnectHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn PlayerDisconnectHandler The PlayerDisconnectHandler instance
--
function PlayerDisconnectHandler:__construct(_parentGemaMode)

  local instance = BaseEventHandler(_parentGemaMode);
  setmetatable(instance, {__index = PlayerDisconnectHandler});

  return instance;

end

getmetatable(PlayerDisconnectHandler).__call = PlayerDisconnectHandler.__construct;


-- Class Methods

---
-- Event handler which is called when a player disconnects.
--
-- @tparam int _cn The client number of the player who disconnected
-- @tparam int _reason The disconnect reason
--
function PlayerDisconnectHandler:handleEvent(_cn, _reason)

  if (_reason == DISC_BANREFUSE) then

    -- This message is printed on player disconnect because on player disconnect after
    -- the getname() method will return nil for the _cn
    self.output:printTextTemplate(
      TextTemplate("InfoMessages/Player/PlayerDisconnectBanned", { ["playerName"] = getname(_cn) })
    );
  end

end


return PlayerDisconnectHandler;
