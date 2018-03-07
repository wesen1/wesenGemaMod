---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- 

local MapChecker = require("Maps/MapChecker");
local Map = require("Maps/Map");
local Output = require("Outputs/Output");


---
-- Class that handles player sent maps.
--
local PlayerSendMapHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
-- 
-- @param GemaMod parentGemaMod
-- 
PlayerSendMapHandler.parentGemaMod = "";


---
-- MapChangeHandler constructor.
-- 
-- @param GemaMod _parentGemaMod The parent gema mod
--
function PlayerSendMapHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerSendMapHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;
  
end


---
-- Event handler which is called when a player tries to send a map to the server.
-- Checks whether the map is a gema and rejects or accepts the upload
-- Saves the map name in the database if it accepts the upload
-- 
-- @param _mapName (String) The map name
-- @param _cn (int) The client number of the player
-- @param _revision (int) The map revision
-- @param _mapSize
-- @param _cfgsize
-- @param _cfgsizegz
-- @param _uploadError
--
function PlayerSendMapHandler:onPlayerSendMap(_mapName, _cn, _revision, _mapsize, _cfgsize, _cfgsizegz, _uploadError)

  if (not MapChecker:isGema(_mapName)) then

    local errorMessage = "This map is not a gema map! Make sure your map name contains g3/ema/@/4";
    Output:print(Output:getColor("error") .. errorMessage, _cn);

    -- returns the Upload Error "Ignore" which will make the server ignore the upload
    -- and print an error message to the player
    return UE_IGNORE;

  elseif (_uploadError == UE_NOERROR) then
    -- if upload is not rejected
    Map:saveMapName(self.parentGemaMod:getDataBase(), _mapName);
    
  end

end


return PlayerSendMapHandler;
