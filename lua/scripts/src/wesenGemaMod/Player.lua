---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

---
-- Stores information about a single player.
--
local Player = {};

---
-- @field id (int) Id of the player in the database
-- 
Player.id = -1;

---
-- @field name (String) The player name
-- 
Player.name = "";

---
-- @field ip (String) The player ip
-- 
Player.ip = "";

---
-- @field level (int) The player level
--
-- 0 = unarmed
-- 1 = admin
-- 
Player.level = 0;

---
-- @field startTime (int) Spawn time (used to calculate time needed to score)
-- 
Player.startTime = 0;


---
-- Player Constructor.
--
-- @param _name (String) Player name
-- @param _ip (String) Player ip 
--
function Player:__construct(_name, _ip)

  local instance = {};
  setmetatable(instance, {__index = Player});
  
  instance.id = -1;
  instance.name = _name;
  instance.ip = _ip;
  instance.level = 0;
  instance.startTime = 0;
    
  return instance;
  
end


-- Getters and Setters

---
-- Returns the player id in the database.
--
-- @return (int) Player id
--
function Player:getId()
  return self.id;
end

---
-- Sets the player id.
--
-- @param _id (int) Player id
--
function Player:setId(_id)
  self.id = _id;
end

---
-- Returns the player name.
--
-- @return (String) Player name
--
function Player:getName()
  return self.name;
end

---
-- Sets the player name.
--
-- @param _name (String) Player name
--
function Player:setName(_name)
  self.name = _name;
end

---
-- Returns the player ip.
--
-- @return (String) Player ip
--
function Player:getIp()
  return self.ip;
end

---
-- Sets the player ip.
--
-- @param _ip (String) Player ip
--
function Player:setIp(_ip)
  self.ip = _ip;
end

---
-- Returns the player level.
--
-- @return (int) Player level
--
function Player:getLevel()
  return self.level;
end

---
-- Sets the player Level.
--
-- @param _level (int) Player level
--
function Player:setLevel(_level)
  self.level = _level;
end

---
-- Returns the start time.
--
-- @return (int) Start time
--
function Player:getStartTime()
  return self.startTime;
end

---
-- Sets the start time.
--
-- @param _startTime (int) Start time
--
function Player:setStartTime(_startTime)
  self.startTime = _startTime;
end


---
-- Fetches the ip id of this player ip from the database.
--
-- @param DataBase _dataBase The database
--
-- @return (int) Ip id
--
function Player:fetchIpId(_dataBase)

  local sql = "SELECT id "
           .. "FROM ips "
           .. "WHERE ip = '" .. self.ip .. "';";
           
  local result = _dataBase:query(sql, true);
  
  if (#result == 0) then
    return nil;
  else
    return tonumber(result[1].id);
  end

end

---
-- Saves the player ip to the database.
-- 
-- @param DataBase _dataBase The database
--
function Player:saveIp(_dataBase)

  if (self:fetchIpId(_dataBase) == nil) then
    local sql = "INSERT INTO ips "
               .. "(ip) "
               .. "VALUES ('" .. self.ip .. "');";
       
    _dataBase:query(sql, false);
    
  end
  
end

---
-- Fetches the id of this player name from the database.
-- 
-- @param DataBase _dataBase The database
--
-- @return (int) Id of this player name
--
function Player:fetchNameId(_dataBase)

  local playerName = _dataBase:sanitize(self.name);

  -- must use the keyword BINARY in order to make the string comparison case sensitve
  local sqlGetId = "SELECT id "
                .. "FROM names "
                .. "WHERE name= BINARY '" .. playerName .. "';";
           
  local result = _dataBase:query(sqlGetId, true);

  if (#result == 0) then
    return nil;
  else
    return tonumber(result[1]["id"]);
  end

end

---
-- Saves the player name to the database.
-- 
-- @param DataBase _dataBase The database
--
function Player:saveName(_dataBase)

  local playerName = _dataBase:sanitize(self.name);

  if (self:fetchNameId(_dataBase) == nil) then

    local sql = "INSERT INTO names "
             .. "(name) "
             .. "VALUES ('" .. playerName .. "');";

    _dataBase:query(sql, false);
    
  end

end

---
-- Fetches the id of the player from the database
-- 
-- @param DataBase _dataBase The database
--
-- @return (nil|int) nil or player id
--
function Player:fetchPlayerId(_dataBase)

  local nameId = self:fetchNameId(_dataBase);
  local ipId = self:fetchIpId(_dataBase);

  local sql = "SELECT id "
           .. "FROM players "
           .. "WHERE name=" .. nameId .. " and ip=" .. ipId .. ";";
           
  local result = _dataBase:query(sql, true);
  
  if (#result == 0) then
    return nil;
  else
    return tonumber(result[1]["id"]);
  end
  
end

---
-- Saves the player (combination of ip and name) in the database.
-- Also sets the id attribute
-- 
-- @param DataBase _dataBase The database
--
function Player:savePlayerData(_dataBase)

  self:saveName(_dataBase);
  self:saveIp(_dataBase);
  
  local nameId = self:fetchNameId(_dataBase);
  local ipId = self:fetchIpId(_dataBase);
  local playerId = self:fetchPlayerId(_dataBase);

  if (self.playerId == nil) then

    local sql = "INSERT INTO players "
       .. "(name, ip) "
       .. "VALUES (" .. nameId .. "," .. ipId .. ");";
              
    _dataBase:query(sql, false);
    playerId = self:fetchPlayerId(_dataBase);
    
  end
  
  self.id = playerId;

end


return Player;
