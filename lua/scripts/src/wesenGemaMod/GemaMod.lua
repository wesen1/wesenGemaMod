---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local DataBase = require("DataBase");
local MapTop = require("Tops/MapTop/MapTop");
local CommandHandler = require("CommandHandler/CommandHandler");
local Player = require("Player");
local EventHandler = require("EventHandler");


---
-- @type GemaMod Wrapper class for the gema mod.
--
local GemaMod = {};


---
-- The database
--
-- @tfield DataBase dataBase
--
GemaMod.dataBase = "";

---
-- The command handler
--
-- @tfield CommandHandler commandHandler
--
GemaMod.commandHandler = "";

---
-- The map top
--local Output = require("Outputs/Output");
-- @tfield MapTop mapTop
--
GemaMod.mapTop = "";

---
-- The list of players
--
-- @tfield Player[] players
--
GemaMod.players = {};

---
-- The event handler
--
-- @tfield EventHandler eventHandler
--
GemaMod.eventHandler = "";


---
-- Gema mod constructor.
--
function GemaMod:__construct(_dataBaseUser, _dataBasePassword, _dataBaseName)

  local instance = {};
  setmetatable(instance, {__index = GemaMod});

  instance.dataBase = DataBase:__construct(_dataBaseUser, _dataBasePassword, _dataBaseName);
  instance.commandHandler = CommandHandler:__construct(instance);
  instance.mapTop = MapTop:__construct(instance);
  instance.players = {};
  instance.eventHandler = EventHandler:__construct(instance);

  return instance;

end


-- Getters and setters





-- Class Methods

function GemaMod:initialize()
  
  print("Loading commands ...");
  self.commandHandler:loadCommands();
  
end


function GemaMod:getDataBase()
  return self.dataBase;
end

function GemaMod:getCommandHandler()
  return self.commandHandler;
end

---
-- Returns the map top.
-- 
-- @return MapTop The map top
--
function GemaMod:getMapTop()
  return self.mapTop;
end

---
-- Returns the player list
-- 
-- @return Player[] The player list
--
function GemaMod:getPlayers()
  return self.players;
end

function GemaMod:getOutput()
  return self.output;
end


---
-- Adds a player to the current list of players.
-- 
-- @param int _cn The client number of the player
--
function GemaMod:addPlayer(_cn)

  local playerIp = getip(_cn);
  local playerName = getname(_cn);

  self.players[_cn] = Player:__construct(playerName, playerIp);
  self.players[_cn]:savePlayerData(self.dataBase);

end

function GemaMod:removePlayer(_cn)
  self.players[_cn] = nil;
end


-- Event handlers

function GemaMod:onFlagAction(_cn, _action, _flag)
  self.eventHandler:getFlagActionHandler():onFlagAction(_cn, _action, _flag);
end

function GemaMod:onMapChange(_mapName)
  self.eventHandler:getMapChangeHandler():onMapChange(_mapName);
end

function GemaMod:onPlayerCallVote(_cn, _type, _text, _number1, _number2, _voteError)

  local pluginBlock = self.eventHandler:getPlayerCallVoteHandler():onPlayerCallVote(_cn, _type, _text, _number1, _number2, _voteError);
  
  if (pluginBlock) then
    return pluginBlock;
  end
  
end

function GemaMod:onPlayerConnect(_cn)
  self.eventHandler:getPlayerConnectHandler():onPlayerConnect(_cn);
end

function GemaMod:onPlayerDisconnect(_cn, _reason)
  self.eventHandler:getPlayerDisconnectHandler():onPlayerDisconnect(_cn, _reason);
end

function GemaMod:onPlayerNameChange(_cn, _newName)
  self.eventHandler:getPlayerNameChangeHandler():onPlayerNameChange(_cn, _newName);
end

function GemaMod:onPlayerRoleChange (_cn, _newRole)
  self.eventHandler:getPlayerRoleChangeHandler():onPlayerRoleChange(_cn, _newRole);
end

function GemaMod:onPlayerSayText(_cn, _text)

  local pluginBlock = self.eventHandler:getPlayerSayTextHandler():onPlayerSayText(_cn, _text);

  if (pluginBlock) then
    return pluginBlock;
  end

end

function GemaMod:onPlayerSendMap(_mapName, _cn, _revision, _mapsize, _cfgsize, _cfgsizegz, _uploadError)

  local uploadError = self.eventHandler:getPlayerSendMapHandler():onPlayerSendMap(_mapName, _cn, _revision, _mapsize, _cfgsize, _cfgsizegz, _uploadError);

  if (uploadError) then
    return uploadError;
  end

end

function GemaMod:onPlayerSpawn(_cn)
  self.eventHandler:getPlayerSpawnHandler():onPlayerSpawn(_cn);
end


return GemaMod;
