---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");

---
-- Class that handles player connects.
-- PlayerConnectHandler inherits from BaseEventHandler
--
-- @type PlayerConnectHandler
--
local PlayerConnectHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- PlayerConnectHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn PlayerConnectHandler The PlayerConnectHandler instance
--
function PlayerConnectHandler:__construct(_parentGemaMode)

  local instance = BaseEventHandler(_parentGemaMode, "onPlayerConnect");
  setmetatable(instance, {__index = PlayerConnectHandler});

  return instance;

end

getmetatable(PlayerConnectHandler).__call = PlayerConnectHandler.__construct;


-- Public Methods

---
-- Event handler which is called when a player connects.
--
-- @tparam int _cn The client number of the player who connected
--
function PlayerConnectHandler:handleEvent(_cn)

  local playerList = self.parentGemaMode:getPlayerList();

  -- Get the Player object for the new connected player
  local player = playerList:getPlayer(_cn);

  if (self.parentGemaMode:getIsActive()) then
  else
    self.output:printTextTemplate("TextTemplate/InfoMessages/GemaModeState/GemaModeNotEnabled", {}, player)
  end

end


return PlayerConnectHandler;
