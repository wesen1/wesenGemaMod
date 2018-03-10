---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Output = require("Outputs/Output");

---
-- Class that handles player disconnects.
--
-- @type PlayerDisconnectHandler
--
local PlayerDisconnectHandler = {};


---
-- The parent gema mod to which this EventHandler belongs.
--
-- @tfield GemaMod parentGemaMod
--
PlayerDisconnectHandler.parentGemaMod = "";


---
-- PlayerDisconnectHandler constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn PlayerDisconnectHandler The PlayerDisconnectHandler instance
--
function PlayerDisconnectHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerDisconnectHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;

end


-- Getters and setters

---
-- Returns the parent gema mod.
--
-- @treturn GemaMod The parent gema mod
--
function PlayerDisconnectHandler:getParentGemaMod()
  return self.parentGemaMod;
end

---
-- Sets the parent gema mod.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
function PlayerDisconnectHandler:setParentGemaMod(_parentGemaMod)
  self.parentGemaMod = _parentGemaMod;
end


-- Class Methods

---
-- Event handler which is called when a player disconnects.
-- Unsets the player object of the cn and prints an error message in case of a banned player trying to connect
--
-- @tparam int _cn The client number of the player who disconnected
-- @tparam int _reason The disconnect reason
--
function PlayerDisconnectHandler:onPlayerDisconnect(_cn, _reason)

  if (_reason == DISC_BANREFUSE) then

    local errorMessage = string.format("Error: %s could not connect [banned]", getname(_cn));
    Output:print(Output:getColor("error") .. errorMessage);

  end

  self.parentGemaMod:removePlayer(_cn);

end


return PlayerDisconnectHandler;
