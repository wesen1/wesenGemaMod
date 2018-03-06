---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- 

local Output = require("Outputs/Output");
local Player = require("Player");


---
-- Class that handles player connects.
--
local PlayerConnectHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
-- 
-- @param GemaMod parentGemaMod
-- 
PlayerConnectHandler.parentGemaMod = "";

---
-- The maximum allowed amount of connections with the same ip to the server
PlayerConnectHandler.maximumAmountConnectionsWithSameIp = 2;


---
-- PlayerConnectHandler constructor.
-- 
-- @param GemaMod _parentGemaMod The parent gema mod
--
function PlayerConnectHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerConnectHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;
  
end


---
-- Event handler which is called when a player connects.
--
-- @param int _cn Client number of the player
--
function PlayerConnectHandler:onPlayerConnect(_cn)

  if (#self.parentGemaMod:getPlayers() == 0) then
    setautoteam (false);
  end  
  
  self:checkAmountConnections(_cn);
  self.parentGemaMod:addPlayer(_cn);
  self:printServerInformation(_cn);

end

---
-- Checks the amount of connections of a specific ip and disconnects the client if there are too many connections.
-- 
-- @param int _cn The client number of the player
-- 
function PlayerConnectHandler:checkAmountConnections(_cn)

  if (self:countConnections(_cn) > self.maximumAmountConnectionsWithSameIp) then
    
    Output:print(Output:getColor("error") .. "Error: " .. getname(_cn) .. " could not connect [too many connections with same IP]");
    disconnect(_cn, DISC_NONE);
  end
  
end

---
-- Returns how many connections a specific ip has to the server.
--
-- @param string _ip The ip address
--
-- @return int The amount of connections
--
function PlayerConnectHandler:countConnections(_cn)

  local ip = getip(_cn);

  -- count connections is called faster than the players list is updated
  local amountConnections = 0;
      
  for i = 0, 15, 1 do
  
    if isconnected(i) and getip(i) == ip then
      amountConnections = amountConnections + 1
    end
  
  end
  
  return amountConnections;

end


---
-- Prints the map statistics and information about the commands to a player.
-- 
-- @param int _cn The client number of the player
--
function PlayerConnectHandler:printServerInformation(_cn)

  self.parentGemaMod:getMapTop():printMapStatistics(_cn);

  local helpText = Output:getColor("info") .. "Say "
                .. Output:getColor("command0") .. "!cmds "
                .. Output:getColor("info") .. "to see a list of avaiable commands";
  Output:print(helpText, _cn);

end


return PlayerConnectHandler;
