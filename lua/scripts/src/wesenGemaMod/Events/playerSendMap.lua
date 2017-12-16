---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

require("Output");
require("MapChecker");

---
-- Event handler which is called when a player tries to send a map to the server.
-- Checks whether the map is a gema and rejects or accepts the upload
-- Saves the map name in the database if it accepts the upload
--
function onPlayerSendMap(_mapName, _cn, _revision, _mapsize, _cfgsize, _cfgsizegz, _uploadError)

  if (not MapChecker:isGema(_mapName)) then

    local errorMessage = "This map is not a gema map! Make sure your map name contains g3/ema/@/4";
    Output:print(colorLoader:getColor("error") .. errorMessage, _cn);

    -- returns the Upload Error "Ignore" which will make the server ignore the upload
    -- and print an error message to the player
    return UE_IGNORE;

  elseif (_uploadError == UE_NOERROR) then
    -- if upload is not rejected
    Map:saveMapName(_mapName);
    
  end

end