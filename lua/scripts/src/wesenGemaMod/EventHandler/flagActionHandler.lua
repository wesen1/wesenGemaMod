---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- 

local MapRecord = require("Tops/MapTop/MapRecord/MapRecord");
local TableUtils = require("Utils/TableUtils");


---
-- Class that handles flag actions.
--
local FlagActionHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
-- 
-- @param GemaMod parentGemaMod
-- 
FlagActionHandler.parentGemaMod = "";


---
-- FlagActionHandler constructor.
-- 
-- @param GemaMod _parentGemaMod The parent gema mod
--
function FlagActionHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = FlagActionHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;
  
end


---
-- Event handler that is called when the state of the flag is changed
--
-- @param int _cn The client number of the player who changed the state
-- @param int action The id of the flag action
-- @param int flag The id of the flag whose state was changed
--
function FlagActionHandler:onFlagAction(_cn, _action, _flag)

  -- instant flag reset (gameplay affecting)
  if (_action == FA_DROP or _action == FA_LOST) then
    -- self:resetFlag(_cn, _flag)

  elseif (_action == FA_SCORE) then
    self:registerRecord(_cn, getsvtick());
  end
      
end


---
-- Adds a record to the maptop and prints the score message.
-- 
-- @param int _cn The player client number
-- @param int _endTime The time when the player scored
--
function FlagActionHandler:registerRecord(_cn, _endTime)

  local scorePlayer = self.parentGemaMod:getPlayers()[_cn];
        
  -- If the player scores again
  if scorePlayer:getStartTime() == 0 then
    return;
  end

  local delta = _endTime - scorePlayer:getStartTime();
  scorePlayer:setStartTime(0);

  if delta == 0 then
    return;
  end
    
  local record = MapRecord:__construct(TableUtils:copy(scorePlayer), delta, self.parentGemaMod:getMapTop());
  record:printScoreRecord();
  self.parentGemaMod:getMapTop():addRecord(record);

end

---
-- Triggers the flag action that the player with _cn returned the flag.
-- 
-- @param int _cn The player client number
-- @param int _flag The flag id
--
function FlagActionHandler:resetFlag(_cn, _flag)
  flagaction(_cn, FA_RESET, _flag);
end


return FlagActionHandler;
