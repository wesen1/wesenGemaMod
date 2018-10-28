---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local PlayerInformationLoader = require("Player/PlayerInformationLoader");
local PlayerInformationSaver = require("Player/PlayerInformationSaver");
local PlayerScoreAttempt = require("Player/PlayerScoreAttempt");
local StringUtils = require("Util/StringUtils");

---
-- Stores information about a single player.
--
-- @type Player
--
local Player = setmetatable({}, {});


---
-- The id of the player in the database
--
-- @tfield int id
--
Player.id = -1;

---
-- The client number of the player
--
-- @tfield int cn
--
Player.cn = -1;

---
-- The player name
--
-- @tfield string name
--
Player.name = "";

---
-- The player ip
--
-- @tfield string ip
--
Player.ip = "";

---
-- The player level (0 = unarmed, 1 = admin)
--
-- @tfield int level
--
Player.level = 0;

---
-- The players score attempt
--
-- @tfield PlayerScoreAttempt scoreAttempt
--
Player.scoreAttempt = nil;


---
-- Player Constructor.
--
-- @tparam int _cn The client number of the player
-- @tparam string _name The player name
-- @tparam string _ip The player ip
--
-- @treturn Player The Player instance
--
function Player:__construct(_cn, _name, _ip)

  local instance = setmetatable({}, {__index = Player});

  instance.id = -1;
  instance.cn = _cn;
  instance.name = _name;
  instance.ip = _ip;
  instance.level = 0;
  instance.scoreAttempt = PlayerScoreAttempt(instance);

  return instance;

end

getmetatable(Player).__call = Player.__construct;


---
-- Returns whether a player object equals this player.
--
-- @treturn Bool True if the ip and name match, false otherwise
--
function Player:equals(_player)

  if (self.ip == _player:getIp() and self.name == _player:getName()) then
    return true;
  else
    return false;
  end

end


-- Getters and Setters

---
-- Returns the player id in the database.
--
-- @treturn int The player id
--
function Player:getId()
  return self.id;
end

---
-- Sets the player id.
--
-- @tparam int _id The player id
--
function Player:setId(_id)
  self.id = _id;
end

---
-- Returns the client number of the player.
--
-- @treturn int The client number of the player
--
function Player:getCn()
  return self.cn;
end

---
-- Returns the player name.
--
-- @treturn string The player name
--
function Player:getName()
  return self.name;
end

---
-- Sets the player name.
--
-- @tparam string _name The player name
--
function Player:setName(_name)
  self.name = _name;
end

---
-- Returns the player ip.
--
-- @treturn string The player ip
--
function Player:getIp()
  return self.ip;
end

---
-- Sets the player ip.
--
-- @tparam string _ip The player ip
--
function Player:setIp(_ip)
  self.ip = _ip;
end

---
-- Returns the player level.
--
-- @treturn int The player level
--
function Player:getLevel()
  return self.level;
end

---
-- Sets the player Level.
--
-- @tparam int _level The player level
--
function Player:setLevel(_level)
  self.level = _level;
end

---
-- Returns the players score attempt.
--
-- @treturn PlayerScoreAttempt The players score attempt
--
function Player:getScoreAttempt()
  return self.scoreAttempt;
end


-- Class Methods

---
-- Returns the ip with the last octet replaced by "x".
--
-- @treturn string The ip with the last octet replaced by "x"
--
function Player:getIpString()

  local ipOctets = StringUtils:split(self.ip, "%.");
  return ipOctets[1] .. "." .. ipOctets[2] .. "." .. ipOctets[3] .. ".x";

end

---
-- Saves the player (combination of ip and name) in the database.
-- Also sets the player id attribute
--
-- @tparam DataBase _dataBase The data base object
--
function Player:savePlayer(_dataBase)

  PlayerInformationSaver:savePlayer(_dataBase, self);
  self.id = PlayerInformationLoader:fetchPlayerId(_dataBase, self);

end


return Player;
