---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

require("MapRecord");

--
-- Event handler which is called when the state of the flag is changed
--
-- @param int _cn     Client number of the player who changed the state
-- @param int action  Id of the flag action
-- @param int flag    Id of the flag whose state was changed
--
function onFlagAction(_cn, _action, _flag)

  -- instant flag reset (gameplay affecting)
  if (_action == FA_DROP or _action == FA_LOST) then
    -- flagaction (_cn, FA_RESET, _flag);

  elseif (_action == FA_SCORE) then
        
    -- if player scores again
    if players[_cn]:getStartTime() == 0 then
      return;
    end

    local delta = getsvtick() - players[_cn]:getStartTime();
    players[_cn]:setStartTime(0);

    if delta == 0 then
      return;
    end
    
    local record = MapRecord:__construct(copy(players[_cn]), delta, mapTop);
    record:printScoreRecord();
    mapTop:addRecord(record);
    
  end
  
end