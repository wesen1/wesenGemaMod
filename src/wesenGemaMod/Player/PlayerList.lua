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


---
-- The list of players
--
-- @tfield Player[] players
--
PlayerList.players = nil;


---
-- PlayerList constructor.
--
-- @treturn PlayerList The PlayerList instance
--
function PlayerList:__construct()

  local instance = setmetatable({}, { __index = PlayerList });

  instance.players = {};

  return instance;

end

getmetatable(PlayerList).__call = PlayerList.__construct;


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
-- Adds a player to the players list.
--
-- @tparam DataBase _dataBase The database
-- @tparam int _cn The client number of the player
--
function PlayerList:addPlayer(_dataBase, _cn)

  local playerIp = getip(_cn);
  local playerName = getname(_cn);

  self.players[_cn] = Player(_cn, playerName, playerIp);
  self.players[_cn]:savePlayer(_dataBase);

end

---
-- Removes a player from the players list.
--
-- @tparam int _cn The client number of the player
--
function PlayerList:removePlayer(_cn)
  self.players[_cn] = nil;
end

---
-- Returns a player with a specific client number.
--
-- @tparam int _cn The client number of the player
--
-- @treturn Player The player
--
function PlayerList:getPlayer(_cn)
  return self.players[_cn];
end

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
