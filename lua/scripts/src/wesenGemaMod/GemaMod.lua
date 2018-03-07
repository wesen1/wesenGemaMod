---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- 

local DataBase = require("DataBase");
local MapTop = require("Tops/MapTop/MapTop");
local CommandHandler = require("CommandHandler/CommandHandler");
local Output = require("Outputs/Output");
local Player = require("Player");

-- Event handlers
local FlagActionHandler = require("EventHandler/flagActionHandler");
local MapChangeHandler = require("EventHandler/mapChangeHandler");
local PlayerCallVoteHandler = require("EventHandler/playerCallVoteHandler");
local PlayerConnectHandler = require("EventHandler/playerConnectHandler");
local PlayerDisconnectHandler = require("EventHandler/playerDisconnectHandler");
local PlayerNameChangeHandler = require("EventHandler/playerNameChangeHandler");
local PlayerRoleChangeHandler = require("EventHandler/playerRoleChangeHandler");
local PlayerSayTextHandler = require("EventHandler/playerSayTextHandler");
local PlayerSendMapHandler = require("EventHandler/playerSendMapHandler");
local PlayerSpawnHandler = require("EventHandler/playerSpawnHandler");


---
-- Wrapper clas for the gema mod.
--
local GemaMod = {};

-- Attributes



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
  instance.output = Output;
  
  -- Event handlers
  instance.flagActionHandler = FlagActionHandler:__construct(instance);
  instance.mapChangeHandler = MapChangeHandler:__construct(instance);
  instance.playerCallVoteHandler = PlayerCallVoteHandler:__construct(instance);
  instance.playerConnectHandler = PlayerConnectHandler:__construct(instance);
  instance.playerDisconnectHandler = PlayerDisconnectHandler:__construct(instance);
  instance.playerNameChangeHandler = PlayerNameChangeHandler:__construct(instance);
  instance.playerRoleChangeHandler = PlayerRoleChangeHandler:__construct(instance);
  instance.playerSayTextHandler = PlayerSayTextHandler:__construct(instance);
  instance.playerSendMapHandler = PlayerSendMapHandler:__construct(instance);
  instance.playerSpawnHandler = PlayerSpawnHandler:__construct(instance);
  
  return instance;
  
end


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
  self.flagActionHandler:onFlagAction(_cn, _action, _flag);
end

function GemaMod:onMapChange(_mapName)
  self.mapChangeHandler:onMapChange(_mapName);
end

function GemaMod:onPlayerCallVote(_cn, _type, _text, _number1, _number2, _voteError)

  local pluginBlock = self.playerCallVoteHandler:onPlayerCallVote(_cn, _type, _text, _number1, _number2, _voteError);
  
  if (pluginBlock) then
    return pluginBlock;
  end
  
end

function GemaMod:onPlayerConnect(_cn)
  self.playerConnectHandler:onPlayerConnect(_cn);
end

function GemaMod:onPlayerDisconnect(_cn, _reason)
  self.playerDisconnectHandler:onPlayerDisconnect(_cn, _reason);
end

function GemaMod:onPlayerNameChange(_cn, _newName)
  self.playerNameChangeHandler:onPlayerNameChange(_cn, _newName);
end

function GemaMod:onPlayerRoleChange (_cn, _newRole)
  self.playerRoleChangeHandler:onPlayerRoleChange(_cn, _newRole);
end

function GemaMod:onPlayerSayText(_cn, _text)

  local pluginBlock = self.playerSayTextHandler:onPlayerSayText(_cn, _text);

  if (pluginBlock) then
    return pluginBlock;
  end

end

function GemaMod:onPlayerSendMap(_mapName, _cn, _revision, _mapsize, _cfgsize, _cfgsizegz, _uploadError)

  local uploadError = self.playerSendMapHandler:onPlayerSendMap(_mapName, _cn, _revision, _mapsize, _cfgsize, _cfgsizegz, _uploadError);

  if (uploadError) then
    return uploadError;
  end

end

function GemaMod:onPlayerSpawn(_cn)
  self.playerSpawnHandler:onPlayerSpawn(_cn);
end


return GemaMod;
