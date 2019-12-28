---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local MapChecker = require("Maps/MapChecker");
local Map = require("Maps/Map");
local Output = require("Outputs/Output");

---
-- Class that handles player sent maps.
--
-- @type PlayerSendMapHandler
--
local PlayerSendMapHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
--
-- @tfield GemaMod parentGemaMod
--
PlayerSendMapHandler.parentGemaMod = "";


---
-- PlayerSendMapHandler constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn PlayerSendMapHandler The PlayerSendMapHandler instance
--
function PlayerSendMapHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerSendMapHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;

end


-- Getters and setters

---
-- Returns the parent gema mod.
--
-- @treturn GemaMod The parent gema mod
--
function PlayerSendMapHandler:getParentGemaMod()
  return self.parentGemaMod;
end

---
-- Sets the parent gema mod.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
function PlayerSendMapHandler:setParentGemaMod(_parentGemaMod)
  self.parentGemaMod = _parentGemaMod;
end


-- Class Methods

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
function PlayerSendMapHandler:onPlayerSendMap(_mapName, _cn, _revision, _mapsize, _cfgsize, _cfgsizegz, _uploadError)

  -- if upload is not rejected
  if (_uploadError == UE_NOERROR) then

    if (MapChecker:isGema(_mapName)) then

      local uploadPlayer = self.parentGemaMod:getPlayers()[_cn];

      Map:saveMapName(self.parentGemaMod:getDataBase(), _mapName, uploadPlayer);
      self.parentGemaMod:getMapRotEditor():addMapToMapRotConfigFile(_mapName);
      self.parentGemaMod:getMapRotEditor():addMapToLoadedMapRot(_mapName);

    end

  end

end


return PlayerSendMapHandler;
