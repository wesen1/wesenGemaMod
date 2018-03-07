---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- 
PLUGIN_NAME = "wesen's basic gema mod";
PLUGIN_AUTHOR = "wesen";
PLUGIN_VERSION = 0.1;

-- 
-- Add the path to the wesenGemaMod classes to the package path list
-- in order to be able to omit this path portion in require() calls
--
package.path = package.path .. ";./lua/scripts/src/wesenGemaMod/?.lua";

local GemaMod = require("GemaMod");

-- Database login credentials
local dataBaseUser = "assaultcube";
local dataBasePassword = "password";
local dataBaseName = "assaultcube_gema";

local gemaMod = GemaMod:__construct(dataBaseUser, dataBasePassword, dataBaseName);
gemaMod:initialize();


-- Bind events to the event handlers

function onFlagAction(_cn, _action, _flag)
  gemaMod:onFlagAction(_cn, _action, _flag);
end

function onMapChange(_mapName)
  gemaMod:onMapChange(_mapName);
end

function onPlayerCallVote(_cn, _type, _text, _number1, _number2, _voteError)

  local pluginBlock = gemaMod:onPlayerCallVote(_cn, _type, _text, _number1, _number2, _voteError);

  if (pluginBlock) then
    return pluginBlock;
  end

end

function onPlayerConnect(_cn)
  gemaMod:onPlayerConnect(_cn);
end

function onPlayerDisconnect(_cn, _reason)
  gemaMod:onPlayerDisconnect(_cn, _reason);
end

function onPlayerNameChange(_cn, _newName)
  gemaMod:onPlayerNameChange(_cn, _newName);
end

function onPlayerRoleChange (_cn, _newRole)
  gemaMod:onPlayerRoleChange(_cn, _newRole);
end

function onPlayerSayText(_cn, _text)
  local pluginBlock = gemaMod:onPlayerSayText(_cn, _text);

  if (pluginBlock) then
    return pluginBlock;
  end

end

function onPlayerSendMap(_mapName, _cn, _revision, _mapsize, _cfgsize, _cfgsizegz, _uploadError)

  local uploadError = gemaMod:onPlayerSendMap(_mapName, _cn, _revision, _mapsize, _cfgsize, _cfgsizegz, _uploadError);

  if (uploadError) then
    return uploadError;
  end

end

function onPlayerSpawn(_cn)
  gemaMod:onPlayerSpawn(_cn);
end
