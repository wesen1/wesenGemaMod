---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Output = require("Outputs/Output");
local Player = require("Player");

---
-- Class that handles player connects.
--
-- @type PlayerConnectHandler
--
local PlayerConnectHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
--
-- @tfield GemaMod parentGemaMod
--
PlayerConnectHandler.parentGemaMod = "";

---
-- The maximum allowed amount of connections with the same ip to the server
--
-- @tfield int maximumAmountConnectionsWithSameIp
--
PlayerConnectHandler.maximumAmountConnectionsWithSameIp = 2;


---
-- PlayerConnectHandler constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn PlayerConnectHandler The PlayerConnectHandler instance
--
function PlayerConnectHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerConnectHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;

end


-- Getters and setters

---
-- Returns the parent gema mod.
--
-- @treturn GemaMod The parent gema mod
--
function PlayerConnectHandler:getParentGemaMod()
  return self.parentGemaMod;
end

---
-- Sets the parent gema mod.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
function PlayerConnectHandler:setParentGemaMod(_parentGemaMod)
  self.parentGemaMod = _parentGemaMod;
end

---
-- Returns the maximum allowed amount of connections with the same ip.
--
-- @treturn int The maximum allowed amount of connections with the same ip
--
function PlayerConnectHandler:getMaximumAmountConnectionsWithSameIp()
  return self.maximumAmountConnectionsWithSameIp;
end

---
-- Sets the maximum allowed amount of connections with the same ip.
--
-- @tparam int _maximumAmountConnectionsWithSameIp The maximum allowed amount of connections with the same ip
--
function PlayerConnectHandler:setMaximumAmountConnectionsWithSameIp(_maximumAmountConnectionsWithSameIp)
  self.maximumAmountConnectionsWithSameIp = _maximumAmountConnectionsWithSameIp;
end


-- Class Methods

---
-- Event handler which is called when a player connects.
--
-- @tparam int _cn The client number of the player who connected
--
function PlayerConnectHandler:onPlayerConnect(_cn)

  if (self.parentGemaMod:getIsActive()) then

    if (#self.parentGemaMod:getPlayers() == 0) then
      setautoteam (false);
    end

    self:checkAmountConnections(_cn);
    self:printServerInformation(_cn);

  else
    Output:print(Output:getColor("info") .. "[INFO] The gema mode is not enabled. Vote a map in ctf to enable it.", _cn);
  end

  self.parentGemaMod:addPlayer(_cn);

end

---
-- Checks the amount of connections of a specific ip and disconnects the client if there are too many connections.
--
-- @tparam int _cn The client number of the player who connected
--
function PlayerConnectHandler:checkAmountConnections(_cn)

  if (self:countConnections(_cn) > self.maximumAmountConnectionsWithSameIp) then
    Output:print(Output:getColor("info") .. "[INFO] " .. getname(_cn) .. " could not connect [too many connections with same IP]");
    disconnect(_cn, DISC_NONE);
  end

end

---
-- Returns how many connections a specific ip has to the server.
--
-- @tparam int _cn The client number of the player
--
-- @treturn int The amount of connections
--
function PlayerConnectHandler:countConnections(_cn)

  -- countConnections is called before the player list is updated, therefore
  -- isconnected() and getip() are used here instead of an iteration over the player list
  local ip = getip(_cn);

  local amountConnections = 0;

  for i = 0, 15, 1 do

    if (isconnected(i) and getip(i) == ip) then
      amountConnections = amountConnections + 1
    end

  end

  return amountConnections;

end


---
-- Prints the map statistics and information about the commands to a player.
--
-- @tparam int _cn The client number of the player who connected
--
function PlayerConnectHandler:printServerInformation(_cn)

  self.parentGemaMod:getMapTop():printMapStatistics(_cn);

  local helpText = Output:getColor("info") .. "Say "
                .. Output:getColor("command0") .. "!cmds "
                .. Output:getColor("info") .. "to see a list of avaiable commands";
  Output:print(helpText, _cn);

end


return PlayerConnectHandler;
