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
local MapRotEditor = require("Maps/MapRot/MapRotEditor");
local MapRotSwitcher = require("Maps/MapRot/MapRotSwitcher");

---
-- Wrapper class for the gema mod.
--
-- @type GemaMod
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
--
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
-- The map rot editor
--
-- @ŧfield MapRotEditor mapRotEditor
--
GemaMod.mapRotEditor = "";

---
-- Indicates whether the gema mode is currently active.
--
-- @tfield bool isActive
--
GemaMod.isActive = true;

---
-- The time in minutes that the players can add to the remaining time with the !extend command
--
-- @tfield int remainingExtendMinutes
--
GemaMod.remainingExtendMinutes = 0


---
-- Gema mod constructor.
--
-- @tparam string _dataBaseUser The database user
-- @tparam string _dataBasePassword The database users password
-- @tparam string _dataBaseName The name of the database for the gema mod
--
-- @treturn GemaMod The GemaMod instance
--
function GemaMod:__construct(_dataBaseUser, _dataBasePassword, _dataBaseName)

  local instance = {};
  setmetatable(instance, {__index = GemaMod});

  instance.dataBase = DataBase:__construct(_dataBaseUser, _dataBasePassword, _dataBaseName);
  instance.commandHandler = CommandHandler:__construct(instance);
  instance.mapTop = MapTop:__construct(instance);
  instance.players = {};
  instance.eventHandler = EventHandler:__construct(instance);
  instance.mapRotEditor = MapRotEditor:__construct("config/maprot_gema.cfg");
  instance.isActive = true;
  instance.remainingExtendMinutes = 0;

  return instance;

end


-- Getters and setters

---
-- Returns the database.
--
-- @treturn Database The database
--
function GemaMod:getDataBase()
  return self.dataBase;
end

---
-- Sets the database.
--
-- @tparam DataBase _dataBase The database
--
function GemaMod:setDataBase(_dataBase)
  self.dataBase = _dataBase;
end

---
-- Returns the command handler.
--
-- @treturn CommandHandler The command handler
--
function GemaMod:getCommandHandler()
  return self.commandHandler;
end

---
-- Sets the command handler.
--
-- @tparam CommandHandler _commandHandler The command handler
--
function GemaMod:setCommandHandler(_commandHandler)
  self.commandHandler = _commandHandler;
end

---
-- Returns the map top.
-- 
-- @treturn MapTop The map top
--
function GemaMod:getMapTop()
  return self.mapTop;
end

---
-- Sets the map top.
-- 
-- @tparam MapTop _mapTop The map top
--
function GemaMod:setMapTop(_mapTop)
  self.mapTop = _mapTop;
end

---
-- Returns the player list.
-- 
-- @treturn Player[] The player list
--
function GemaMod:getPlayers()
  return self.players;
end

---
-- Sets the player list.
-- 
-- @tparam Player[] _players The player list
--
function GemaMod:setPlayers(_players)
  self.players = _players;
end

---
-- Returns the event handler.
--
-- @treturn EventHandler The event handler
--
function GemaMod:getEventHandler()
  return self.eventHandler;
end

---
-- Sets the event handler.
--
-- @tparam EventHandler _eventHandler The event handler
--
function GemaMod:setEventHandler(_eventHandler)
  self.eventHandler = _eventHandler;
end

---
-- Returns the map rot editor.
--
-- @treturn MapRotEditor mapRotEditor
--
function GemaMod:getMapRotEditor()
  return self.mapRotEditor;
end

---
-- Sets the map rot editor.
--
-- @tparam MapRotEditor _mapRotEditor The map rot editor
--
function GemaMod:setMapRotEditor(_mapRotEditor)
  self.mapRotEditor = _mapRotEditor;
end

---
-- Returns whether the gema mode is active.
--
-- @treturn bool True: Gema mode is active
--               False: Gema mode is not active
--
function GemaMod:getIsActive()
  return self.isActive;
end

---
-- Sets whether the gema mode is active.
--
-- @tparam bool _isActive True: Gema mode is active
--                        False: Gema mode is not active
--
function GemaMod:setIsActive(_isActive)
  self.isActive = _isActive;
end

---
-- Returns the time in minutes that the players can add to the remaining time with the !extend command.
--
-- @treturn int The time in minutes that the players can add to the remaining time with the !extend command
--
function GemaMod:getRemainingExtendMinutes()
  return self.remainingExtendMinutes;
end

---
-- Sets the time in minutes that the players can add to the remaining time with the !extend command.
--
-- @tparam int _remainingExtendMinutes The time in minutes that the players can add
--                                     to the remaining time with the !extend command
--
function GemaMod:setRemainingExtendMinutes(_remainingExtendMinutes)
  self.remainingExtendMinutes = _remainingExtendMinutes;
end


-- Class Methods

---
-- Loads the commands.
--
function GemaMod:initialize()
  print("Loading commands ...");
  self.commandHandler:loadCommands();

  print("Loading gema maps ...");
  self.mapRotEditor:addExistingGemaMapsToDataBase(self.dataBase, "packages/maps/servermaps/incoming");
  self.mapRotEditor:generateMapRotFromExistingMaps(self.dataBase);

  MapRotSwitcher:switchToGemaMapRot();

end

---
-- Adds a player to the players list.
-- 
-- @tparam int _cn The client number of the player
--
function GemaMod:addPlayer(_cn)

  local playerIp = getip(_cn);
  local playerName = getname(_cn);

  self.players[_cn] = Player:__construct(playerName, playerIp);
  self.players[_cn]:savePlayerData(self.dataBase);

end

---
-- Removes a player from the players list.
--
-- @tparam int _cn The client number of the player
--
function GemaMod:removePlayer(_cn)
  self.players[_cn] = nil;
end


-- Event handlers

---
-- Event handler that is called when the state of the flag is changed.
--
-- @tparam int _cn The client number of the player who changed the state
-- @tparam int _action The id of the flag action
-- @tparam int _flag The id of the flag whose state was changed
--
function GemaMod:onFlagAction(_cn, _action, _flag)
  self.eventHandler:getFlagActionHandler():onFlagAction(_cn, _action, _flag);
end

---
-- Event handler which is called when the map is changed.
--
-- @tparam string _mapName The name of the new map
-- @tparam int _gameMode The game mode
--
function GemaMod:onMapChange(_mapName, _gameMode)
  self.eventHandler:getMapChangeHandler():onMapChange(_mapName, _gameMode);
end

---
-- Event handler which is called when a player calls a vote.
--
-- @tparam int _cn The client number of the player that called the vote
-- @tparam int _type The vote type
-- @tparam string _text The map name, kick reason, etc.
-- @tparam int _number1 The game mode, target cn, etc.
-- @tparam int _number2 The time of the map vote, target team of teamchange vote, etc.
-- @tparam int _voteError The vote error
--
-- @treturn int|nil PLUGIN_BLOCK if a voted map is auto removed or nil
--
function GemaMod:onPlayerCallVote(_cn, _type, _text, _number1, _number2, _voteError)

  local pluginBlock = self.eventHandler:getPlayerCallVoteHandler():onPlayerCallVote(_cn, _type, _text, _number1, _number2, _voteError);
  
  if (pluginBlock) then
    return pluginBlock;
  end
  
end

---
-- Event handler which is called when a player connects.
--
-- @tparam int _cn The client number of the player who connected
--
function GemaMod:onPlayerConnect(_cn)
  self.eventHandler:getPlayerConnectHandler():onPlayerConnect(_cn);
end

---
-- Event handler which is called when a player disconnects.
-- Unsets the player object of the cn and prints an error message in case of a banned player trying to connect
--
-- @tparam int _cn The client number of the player who disconnected
-- @tparam int _reason The disconnect reason
--
function GemaMod:onPlayerDisconnect(_cn, _reason)
  self.eventHandler:getPlayerDisconnectHandler():onPlayerDisconnect(_cn, _reason);
end

---
-- Event handler which is called when a player changes his name.
-- Updates the player object and adds a data base entry for the new player ip/name combination.
--
-- @tparam int _cn The client number of the player who changed his name
-- @tparam string _newName The new name of the player
--
function GemaMod:onPlayerNameChange(_cn, _newName)
  self.eventHandler:getPlayerNameChangeHandler():onPlayerNameChange(_cn, _newName);
end

---
-- Event handler which is called when a player role changes (admin login/logout).
-- Sets the player level according to the role change
--
-- @tparam int _cn The client number of the player whose role changed
-- @tparam int _newRole The new role
--
function GemaMod:onPlayerRoleChange (_cn, _newRole)
  self.eventHandler:getPlayerRoleChangeHandler():onPlayerRoleChange(_cn, _newRole);
end

---
-- Event handler which is called when a player says text.
-- Logs the text that the player said and either executes a command or outputs the text to the other players
--
-- @tparam int _cn The client number of the player
-- @tparam string _text The text that the player sent
--
-- @treturn int|nil PLUGIN_BLOCK if the player says normal text or nil
--
function GemaMod:onPlayerSayText(_cn, _text)

  local pluginBlock = self.eventHandler:getPlayerSayTextHandler():onPlayerSayText(_cn, _text);

  if (pluginBlock) then
    return pluginBlock;
  end

end

---
-- Event handler which is called when a player tries to send a map to the server.
-- Checks whether the map is a gema and rejects or accepts the upload
-- Saves the map name in the database if it accepts the upload
--
-- @tparam string _mapName The map name
-- @tparam int _cn The client number of the player
-- @tparam int _revision The map revision
-- @tparam int _mapsize The map size
-- @tparam int _cfgsize The cfg size
-- @tparam int _cfgsizegz The cgz size
-- @tparam int _uploadError The upload error
--
-- @treturn int|nil Upload error if map is not a gema or nil
--
function GemaMod:onPlayerSendMap(_mapName, _cn, _revision, _mapsize, _cfgsize, _cfgsizegz, _uploadError)

  local uploadError = self.eventHandler:getPlayerSendMapHandler():onPlayerSendMap(_mapName, _cn, _revision, _mapsize, _cfgsize, _cfgsizegz, _uploadError);

  if (uploadError) then
    return uploadError;
  end

end

---
-- Event handler that is called when a player shoots.
--
-- @tparam int _cn The client number of the player who shot
-- @tparam int _weapon The weapon with which the player shot
--
function GemaMod:onPlayerShoot(_cn, _weapon)
  self.eventHandler:getPlayerShootHandler():onPlayerShoot(_cn, _weapon);
end

---
-- Event handler which is called when a player spawns.
-- Initializes the start time of the player that spawned
--
-- @tparam int _cn The client number of the player who spawned
--
function GemaMod:onPlayerSpawn(_cn)
  self.eventHandler:getPlayerSpawnHandler():onPlayerSpawn(_cn);
end

---
-- Event handler which is called after a player spawned.
-- Sets the players team and weapon.
--
-- @tparam int _cn The client number of the player who spawned
--
function GemaMod:onPlayerSpawnAfter(_cn)
  self.eventHandler:getPlayerSpawnAfterHandler():onPlayerSpawnAfter(_cn);
end

---
-- Event handler which is called when a vote ends.
--
-- @tparam int _result The result of the vote
-- @tparam int _cn The client number of the player who called the vote
-- @tparam int _type The vote type
-- @tparam string _text The map name, kick reason, etc.
-- @tparam int _number1 The game mode, target cn, etc.
-- @tparam int _number2 The time of the map vote, target team of teamchange vote, etc.
--
function GemaMod:onVoteEnd(_result, _cn, _type, _text, _number1, _number2)
  self.eventHandler:getVoteEndHandler():onVoteEnd(_result, _cn, _type, _text, _number1, _number2);
end


return GemaMod;
