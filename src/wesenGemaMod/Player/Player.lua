---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local PlayerScoreAttempt = require("Player/PlayerScoreAttempt");
local Ip = require("ORM/Models/Ip")
local Name = require("ORM/Models/Name")
local PlayerModel = require("ORM/Models/Player")

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
-- @treturn Player The Player instance
--
function Player:__construct()

  local instance = setmetatable({}, {__index = Player});

  instance.id = -1;
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
-- Saves the player (combination of ip and name) in the database.
-- Also sets the player id attribute
--
function Player:savePlayer()

  -- Find the existing data row for this player
  local player = PlayerModel:get()
                       :innerJoinIps()
                       :innerJoinNames()
                       :where()
                         :column("ips.ip"):equals(self.ip):AND()
                         :column("names.name"):equals(self.name)
                       :findOne()

  if (player == nil) then

    -- Save the ip if necessary
    local ip = Ip:get():filterByIp(self.ip):findOne()
    if (ip == nil) then
      ip = Ip:new({ ip = self.ip })
      ip:save()
    end

    -- Save the name if necessary
    local name = Name:get():filterByName(self.name):findOne()
    if (name == nil) then
      name = Name:new({ name = self.name })
      name:save()
    end

    player = PlayerModel:new({ ip_id = ip.id, name_id = name.id })
    player:save()

  end

  self.id = player.id

end


return Player;
