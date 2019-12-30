---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Player = require("Player/Player");

---
-- Stores a list of Player's and provides methods to add/remove entries from the list.
--
-- @type PlayerList
--
local PlayerList = setmetatable({}, {});



-- Getters and Setters

---
-- Returns the array of Player's.
--
-- @treturn Player[] The array of Player's
--
function PlayerList:getPlayers()
  return self.players;
end


-- Public Methods

---
-- Returns how many connected players have a specific ip.
--
-- @tparam string _ip The ip
--
-- @treturn int The number of connected players with that ip
--
function PlayerList:getNumberOfPlayersWithIp(_ip)

  local numberOfConnections = 0;
  for _, player in pairs(self.players) do
    if (player:getIp() == _ip) then
      numberOfConnections = numberOfConnections + 1;
    end
  end

  return numberOfConnections;

  --[[
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
  --]]

end


return PlayerList;
