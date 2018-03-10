---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local MapRecord = require("Tops/MapTop/MapRecord/MapRecord");
local TableUtils = require("Utils/TableUtils");

---
-- @type FlagActionHandler Class that handles flag actions.
--
local FlagActionHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
--
-- @tfield GemaMod parentGemaMod
--
FlagActionHandler.parentGemaMod = "";


---
-- FlagActionHandler constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn FlagActionHandler The FlagActionHandler instance
--
function FlagActionHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = FlagActionHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;

end


-- Getters and setters

---
-- Returns the parent gema mod.
--
-- @treturn GemaMod The parent gema mod
--
function FlagActionHandler:getParentGemaMod()
  return self.parentGemaMod;
end

---
-- Sets the parent gema mod.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
function FlagActionHandler:setParentGemaMod(_parentGemaMod)
  self.parentGemaMod = _parentGemaMod;
end


-- Class Methods

---
-- Event handler that is called when the state of the flag is changed.
--
-- @param int _cn The client number of the player who changed the state
-- @param int _action The id of the flag action
-- @param int _flag The id of the flag whose state was changed
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
-- @param int _cn The player client number of the player who scored
-- @param int _endTime The time in milliseconds when the player scored
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
-- Triggers the flag action that the player with _cn returns the flag.
--
-- @param int _cn The player client number of the player who dropped the flag
-- @param int _flag The flag id of the flag that was dropped
--
function FlagActionHandler:resetFlag(_cn, _flag)
  flagaction(_cn, FA_RESET, _flag);
end


return FlagActionHandler;
