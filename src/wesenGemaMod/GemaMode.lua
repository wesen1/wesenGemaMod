---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local CommandLoader = require("CommandHandler/CommandLoader");
local DataBase = require("DataBase");
local EventHandler = require("EventHandler");
local GemaModeStateUpdater = require("GemaModeStateUpdater");
local MapRot = require("MapRot/MapRot");
local MapRotGenerator = require("MapRot/MapRotGenerator");
local MapTopHandler = require("Tops/MapTopHandler");
local Output = require("Output/Output");
local PlayerList = require("Player/PlayerList");

---
-- Wrapper class for the gema mode.
--
-- @type GemaMode
--
local GemaMode = setmetatable({}, {});

---
-- The command list
--
-- @tfield CommandList commandList
--
GemaMode.commandList = nil;

---
-- The command loader
--
-- @tfield CommandLoader commandLoader
--
GemaMode.commandLoader = nil;

---
-- The database
--
-- @tfield DataBase dataBase
--
GemaMode.dataBase = nil;

---
-- The event handler
--
-- @tfield EventHandler eventHandler
--
GemaMode.eventHandler = nil;

---
-- The gema mode state updater
--
-- @tfield GemaModeStateUpdater gemaModeStateUpdater
--
GemaMode.gemaModeStateUpdater = nil;

---
-- The map top handler
--
-- @tfield MapTopHandler mapTopHandler
--
GemaMode.mapTopHandler = nil;

---
-- The map rot
--
-- @tfield MapRot mapRot
--
GemaMode.mapRot = nil;

---
-- The map rot generator
--
-- @tfield MapRotGenerator mapRotGenerator
--
GemaMode.mapRotGenerator = nil;

---
-- The output
--
-- @tfield Output output
--
GemaMode.output = nil;

---
-- The player list
--
-- @tfield PlayerList playerList
--
GemaMode.playerList = nil;

---
-- Indicates whether the gema mode is currently active
--
-- @tfield bool isActive
--
GemaMode.isActive = nil;


---
-- GemaMode constructor.
--
-- @tparam string _dataBaseUser The database user
-- @tparam string _dataBasePassword The database users password
-- @tparam string _dataBaseName The name of the database for the gema mod
--
-- @treturn GemaMode The GemaMode instance
--
function GemaMode:__construct(_dataBaseUser, _dataBasePassword, _dataBaseName)

  local instance = setmetatable({}, {__index = GemaMode});

  instance.commandLoader = CommandLoader();
  instance.dataBase = DataBase(_dataBaseUser, _dataBasePassword, _dataBaseName);
  instance.mapRot = MapRot("config/maprot_gema.cfg");
  instance.mapRotGenerator = MapRotGenerator();
  instance.output = Output();
  instance.playerList = PlayerList();

  -- Must be created after the output was created
  instance.eventHandler = EventHandler(instance);
  instance.mapTopHandler = MapTopHandler(instance.output);

  -- Must be created after the map rot was created
  instance.gemaModeStateUpdater = GemaModeStateUpdater(instance);

  --@todo: Config value for this
  instance.isActive = true;

  return instance;

end

getmetatable(GemaMode).__call = GemaMode.__construct;


-- Getters and setters

---
-- Returns the command list.
--
-- @treturn CommandList The command list
--
function GemaMode:getCommandList()
  return self.commandList;
end

---
-- Returns the command loader.
--
-- @treturn CommandLoader The command loader
--
function GemaMode:getCommandLoader()
  return self.commandLoader;
end

---
-- Returns the database.
--
-- @treturn Database The database
--
function GemaMode:getDataBase()
  return self.dataBase;
end

---
-- Returns the event handler.
--
-- @treturn EventHandler The event handler
--
function GemaMode:getEventHandler()
  return self.eventHandler;
end

---
-- Returns the gema mode state updater.
--
-- @treturn GemaModeStateUpdater The gema mode state updater
--
function GemaMode:getGemaModeStateUpdater()
  return self.gemaModeStateUpdater;
end

---
-- Returns the map rot.
--
-- @treturn MapRot The map rot
--
function GemaMode:getMapRot()
  return self.mapRot;
end

---
-- Returns the map rot generator.
--
-- @treturn MapRotGenerator The map rot generator
--
function GemaMode:getMapRotGenerator()
  return self.mapRotGenerator;
end

---
-- Returns the map top handler.
--
-- @treturn MapTop The map top handler
--
function GemaMode:getMapTopHandler()
  return self.mapTopHandler;
end

---
-- Returns the output.
--
-- @treturn Output The output
--
function GemaMode:getOutput()
  return self.output;
end

---
-- Returns the player list.
--
-- @treturn PlayerList The player list
--
function GemaMode:getPlayerList()
  return self.playerList;
end

---
-- Returns whether the gema mode is active.
--
-- @treturn bool True if the gema mode is active, false otherwise
--
function GemaMode:getIsActive()
  return self.isActive;
end

---
-- Sets whether the gema mode is active.
--
-- @tparam bool _isActive If true, the gema mode will be active, if false it will be deactivated
--
function GemaMode:setIsActive(_isActive)
  self.isActive = _isActive;
end


-- Public Methods

---
-- Loads the commands and generates the gema maprot.
--
function GemaMode:initialize()

  logline(ACLOG_DEBUG, "Loading commands ...");
  self.commandList = self.commandLoader:loadCommands(self, "lua/scripts/wesenGemaMod/Commands");

  logline(ACLOG_DEBUG, "Generating gema maprot ...");
  self.mapRot:switchToGemaMapRot();
  self.mapRotGenerator:generateGemaMapRot(self.mapRot, "packages/maps/servermaps/incoming");

  logline(ACLOG_DEBUG, "Initializing maptops ...");
  self.mapTopHandler:initialize();

end


-- Event handlers

---
-- Event handler that is called when the state of the flag is changed.
--
-- @tparam int _cn The client number of the player who changed the state
-- @tparam int _action The id of the flag action
-- @tparam int _flag The id of the flag whose state was changed
--
function GemaMode:onFlagAction(_cn, _action, _flag)
  self.eventHandler:getFlagActionHandler():onFlagAction(self.playerList:getPlayer(_cn), _action, _flag);
end

---
-- Event handler which is called when the map is changed.
--
-- @tparam string _mapName The name of the new map
-- @tparam int _gameMode The game mode
--
function GemaMode:onMapChange(_mapName, _gameMode)
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
function GemaMode:onPlayerCallVote(_cn, _type, _text, _number1, _number2, _voteError)

  return self.eventHandler:getPlayerCallVoteHandler():onPlayerCallVote(
    self.playerList:getPlayer(_cn), _type, _text, _number1, _number2, _voteError
  );

end

---
-- Event handler which is called when a player connects.
--
-- @tparam int _cn The client number of the player who connected
--
function GemaMode:onPlayerConnect(_cn)
  self.eventHandler:getPlayerConnectHandler():onPlayerConnect(_cn);
end

---
-- Event handler which is called after a player disconnected.
-- Unsets the player object of the cn and prints an error message in case of a banned player trying to connect
--
-- @tparam int _cn The client number of the player who disconnected
-- @tparam int _reason The disconnect reason
--
function GemaMode:onPlayerDisconnectAfter(_cn, _reason)
  self.eventHandler:getPlayerDisconnectAfterHandler():onPlayerDisconnectAfter(_cn, _reason);
end

---
-- Event handler which is called when a player changes his name.
-- Updates the player object and adds a data base entry for the new player ip/name combination.
--
-- @tparam int _cn The client number of the player who changed his name
-- @tparam string _newName The new name of the player
--
function GemaMode:onPlayerNameChange(_cn, _newName)
  self.eventHandler:getPlayerNameChangeHandler():onPlayerNameChange(self.playerList:getPlayer(_cn), _newName);
end

---
-- Event handler which is called when a player role changes (admin login/logout).
-- Sets the player level according to the role change
--
-- @tparam int _cn The client number of the player whose role changed
-- @tparam int _newRole The new role
--
function GemaMode:onPlayerRoleChange (_cn, _newRole)
  self.eventHandler:getPlayerRoleChangeHandler():onPlayerRoleChange(self.playerList:getPlayer(_cn), _newRole);
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
function GemaMode:onPlayerSayText(_cn, _text)

  return self.eventHandler:getPlayerSayTextHandler():onPlayerSayText(
    self.playerList:getPlayer(_cn), _text
  );

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
function GemaMode:onPlayerSendMap(_mapName, _cn, _revision, _mapsize, _cfgsize, _cfgsizegz, _uploadError)

  return self.eventHandler:getPlayerSendMapHandler():onPlayerSendMap(
    _mapName, self.playerList:getPlayer(_cn), _revision, _mapsize, _cfgsize, _cfgsizegz, _uploadError
  );

end

---
-- Event handler that is called when a player shoots.
--
-- @tparam int _cn The client number of the player who shot
-- @tparam int _weapon The weapon with which the player shot
--
function GemaMode:onPlayerShoot(_cn, _weapon)
  self.eventHandler:getPlayerShootHandler():onPlayerShoot(self.playerList:getPlayer(_cn), _weapon);
end

---
-- Event handler which is called when a player spawns.
-- Initializes the start time of the player that spawned
--
-- @tparam int _cn The client number of the player who spawned
--
function GemaMode:onPlayerSpawn(_cn)
  self.eventHandler:getPlayerSpawnHandler():onPlayerSpawn(self.playerList:getPlayer(_cn));
end

---
-- Event handler which is called after a player spawned.
-- Sets the players team and weapon.
--
-- @tparam int _cn The client number of the player who spawned
--
function GemaMode:onPlayerSpawnAfter(_cn)
  self.eventHandler:getPlayerSpawnAfterHandler():onPlayerSpawnAfter(self.playerList:getPlayer(_cn));
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
function GemaMode:onVoteEnd(_result, _cn, _type, _text, _number1, _number2)
  self.eventHandler:getVoteEndHandler():onVoteEnd(
    _result, self.playerList:getPlayer(_cn), _type, _text, _number1, _number2
  );
end


return GemaMode;
