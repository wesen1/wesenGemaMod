---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--
PLUGIN_NAME = "wesen's gema mod";
PLUGIN_AUTHOR = "wesen";
PLUGIN_VERSION = 0.1;

--
-- Add the path to the wesenGemaMod classes to the package path list
-- in order to be able to omit this path portion in require() calls
--
package.path = package.path .. ";./lua/scripts/src/wesenGemaMod/?.lua";

local GemaMod = require("GemaMod");

local gemaMod = GemaMod:__construct(
  cfg.getvalue("gemamod", "dataBaseUser"),
  cfg.getvalue("gemamod", "dataBasePassword"),
  cfg.getvalue("gemamod", "dataBaseName")
);
gemaMod:initialize();


-- Bind events to the event handlers

---
-- Event handler that is called when the state of the flag is changed.
--
-- @tparam int _cn The client number of the player who changed the state
-- @tparam int _action The id of the flag action
-- @tparam int _flag The id of the flag whose state was changed
--
function onFlagAction(_cn, _action, _flag)
  gemaMod:onFlagAction(_cn, _action, _flag);
end

---
-- Event handler which is called when the map is changed.
--
-- @tparam string _mapName The name of the new map
-- @tparam int _gameMode The game mode
--
function onMapChange(_mapName, _gameMode)
  gemaMod:onMapChange(_mapName, _gameMode);
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
function onPlayerCallVote(_cn, _type, _text, _number1, _number2, _voteError)

  local pluginBlock = gemaMod:onPlayerCallVote(_cn, _type, _text, _number1, _number2, _voteError);

  if (pluginBlock) then
    return pluginBlock;
  end

end

---
-- Event handler which is called when a player connects.
--
-- @tparam int _cn The client number of the player who connected
--
function onPlayerConnect(_cn)
  gemaMod:onPlayerConnect(_cn);
end

---
-- Event handler which is called when a player disconnects.
-- Unsets the player object of the cn and prints an error message in case of a banned player trying to connect
--
-- @tparam int _cn The client number of the player who disconnected
-- @tparam int _reason The disconnect reason
--
function onPlayerDisconnect(_cn, _reason)
  gemaMod:onPlayerDisconnect(_cn, _reason);
end

---
-- Event handler which is called when a player changes his name.
-- Updates the player object and adds a data base entry for the new player ip/name combination.
--
-- @tparam int _cn The client number of the player who changed his name
-- @tparam string _newName The new name of the player
--
function onPlayerNameChange(_cn, _newName)
  gemaMod:onPlayerNameChange(_cn, _newName);
end

---
-- Event handler which is called when a player role changes (admin login/logout).
-- Sets the player level according to the role change
--
-- @tparam int _cn The client number of the player whose role changed
-- @tparam int _newRole The new role
--
function onPlayerRoleChange (_cn, _newRole)
  gemaMod:onPlayerRoleChange(_cn, _newRole);
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
function onPlayerSayText(_cn, _text)

  local pluginBlock = gemaMod:onPlayerSayText(_cn, _text);

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
function onPlayerSendMap(_mapName, _cn, _revision, _mapsize, _cfgsize, _cfgsizegz, _uploadError)

  local uploadError = gemaMod:onPlayerSendMap(_mapName, _cn, _revision, _mapsize, _cfgsize, _cfgsizegz, _uploadError);

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
function onPlayerShoot(_cn, _weapon)
  gemaMod:onPlayerShoot(_cn, _weapon);
end

---
-- Event handler which is called when a player spawns.
-- Initializes the start time of the player that spawned
--
-- @tparam int _cn The client number of the player who spawned
--
function onPlayerSpawn(_cn)
  gemaMod:onPlayerSpawn(_cn);
end

---
-- Event handler which is called after a player spawned.
-- Sets the players team and weapon.
--
-- @tparam int _cn The client number of the player who spawned
--
function onPlayerSpawnAfter(_cn)
  gemaMod:onPlayerSpawnAfter(_cn);
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
function onVoteEnd(_result, _cn, _type, _text, _number1, _number2)
  gemaMod:onVoteEnd(_result, _cn, _type, _text, _number1, _number2);
end
