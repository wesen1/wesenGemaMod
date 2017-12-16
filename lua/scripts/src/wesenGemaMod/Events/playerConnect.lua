---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

require("Player");
require("Output");

--
-- Event handler which is called when a player connects
--
-- @param int _cn   Client number of the player
--
function onPlayerConnect(_cn)
  
  local playerIp = getip(_cn);
  local playerName = getname(_cn);
  
  if (#players == 0) then
    setautoteam (false);
  end  
  
  mapTop:printMapStatistics(_cn);

  local output = colorLoader:getColor("info") .. "Say "
              .. colorLoader:getColor("command0") .. "!cmds "
              .. colorLoader:getColor("info") .. "to see a list of avaiable commands";
  Output:print(output, _cn);
  
  players[_cn] = Player:__construct(playerName, playerIp);
  players[_cn]:savePlayerData();
  
  if (countConnections(playerIp) > 2) then
    Output:print(colorLoader:getColor("error") .. "Error: " .. playerName .. " could not connect [too many connections with same IP]");
    disconnect(_cn, DISC_NONE);
  end

end


--
-- Returns how many connections a specific ip has to the server
--
-- @param string _ip    The ip address
--
-- @return int    Amount of connections
--
function countConnections(_ip)

  -- count connections is called faster than the players list is updated
  local amountConnections = 0;
      
  for i = 0, 15, 1 do
  
    if isconnected(i) and getip(i) == _ip then
      amountConnections = amountConnections + 1
    end
  
  end
  
  return amountConnections;

end