---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");
local MapHandler = require("Map/MapHandler");
local MapNameChecker = require("Map/MapNameChecker");

---
-- Class that handles player sent maps.
-- PlayerSendMapHandler inherits from BaseEventHandler
--
-- @type PlayerSendMapHandler
--
local PlayerSendMapHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- The map name checker
--
-- @tparam MapNameChecker mapNameChecker
--
PlayerSendMapHandler.mapNameChecker = nil;


---
-- PlayerSendMapHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn PlayerSendMapHandler The PlayerSendMapHandler instance
--
function PlayerSendMapHandler:__construct(_parentGemaMode)

  local instance = BaseEventHandler(_parentGemaMode);
  setmetatable(instance, {__index = PlayerSendMapHandler});

  instance.mapNameChecker = MapNameChecker();

  return instance;

end

getmetatable(PlayerSendMapHandler).__call = PlayerSendMapHandler.__construct;


-- Public Methods

---
-- Event handler which is called when a player tries to send a map to the server.
-- Checks whether the map is a gema and rejects or accepts the upload
-- Saves the map name in the database if it accepts the upload
--
-- @tparam string _mapName The map name
-- @tparam Player _player The player
-- @tparam int _revision The map revision
-- @tparam int _mapsize The map size
-- @tparam int _cfgsize The cfg size
-- @tparam int _cfgsizegz The cgz size
-- @tparam int _uploadError The upload error
--
-- @treturn int|nil Upload error if map is not a gema or nil
--
function PlayerSendMapHandler:handleEvent(_mapName, _player, _revision, _mapsize, _cfgsize, _cfgsizegz, _uploadError)

  -- if upload is not rejected
  if (_uploadError == UE_NOERROR) then

    if (self.mapNameChecker:isGemaMapName(_mapName)) then

      local dataBase = self.parentGemaMode:getDataBase();
      MapHandler:saveMap(dataBase, _mapName, _player);

      self.parentGemaMode:getMapRot():addMap(_mapName);
    end

  end

end


return PlayerSendMapHandler;
