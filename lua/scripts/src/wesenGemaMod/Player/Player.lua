---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Output = require("Outputs/Output");
local PlayerInformationLoader = require("Player/PlayerInformationLoader");
local PlayerInformationSaver = require("Player/PlayerInformationSaver");
local StringUtils = require("Utils/StringUtils");

---
-- Stores information about a single player.
--
-- @type Player
--
local Player = {};


---
-- The id of the player in the database
--
-- @tfield int id
--
Player.id = -1;

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
-- The spawn time in milliseconds
-- This value is used to calculate the time that the player needed to score
--
-- @tfield int startTime
--
Player.startTime = 0;

---
-- The current team of the player
--
-- @tfield int team
--
Player.team = -1;

---
-- The current weapon of the player
--
-- @tfield int weapon
--
Player.weapon = -1;

---
-- The color of the texts that the player says to other clients
--
-- @tfield string textColor
--
Player.textColor = Output:getColor("playerTextDefault");


---
-- Player Constructor.
--
-- @tparam string _name The player name
-- @tparam string _ip The player ip
--
-- @treturn Player The Player instance
--
function Player:__construct(_name, _ip)

  local instance = {};
  setmetatable(instance, {__index = Player});

  instance.id = -1;
  instance.name = _name;
  instance.ip = _ip;
  instance.level = 0;
  instance.startTime = 0;
  instance.team = -1;
  instance.weapon = -1;

  return instance;

end

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
-- Returns the start time.
--
-- @treturn int The start time
--
function Player:getStartTime()
  return self.startTime;
end

---
-- Sets the start time.
--
-- @tparam int _startTime The start time
--
function Player:setStartTime(_startTime)
  self.startTime = _startTime;
end

---
-- Returns the current team of the player.
--
-- @treturn int The current team of the player
--
function Player:getTeam()
  return self.team;
end

---
-- Sets the current team of the player.
--
-- @tparam int _team The current team of the player
--
function Player:setTeam(_team)
  self.team = _team;
end

---
-- Returns the current weapon of the player.
--
-- @treturn int The current weapon of the player
--
function Player:getWeapon()
  return self.weapon;
end

---
-- Sets the current weapon of the player.
--
-- @tparam int _weapon The current weapon of the player
--
function Player:setWeapon(_weapon)
  self.weapon = _weapon;
end

---
-- Returns the text color.
--
-- @treturn string The text color
--
function Player:getTextColor()
  return self.textColor;
end

---
-- Sets the text color.
--
-- @tparam string _textColor The text color
--
function Player:setTextColor(_textColor)
  self.textColor = _textColor;
end


-- Class Methods

---
-- Returns the ip with the last octet replaced by "x".
--
-- @treturn string The ip with the last octet replaced by "x"
--
function Player:getIpString()

  local ipOctets = StringUtils:split(self.ip, ".");
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
