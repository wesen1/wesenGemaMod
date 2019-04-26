---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler")

---
-- Class that handles flag actions.
-- FlagActionHandler inherits from BaseEventHandler
--
-- @type FlagActionHandler
--
local FlagActionHandler = setmetatable({}, {__index = BaseEventHandler})


---
-- The map record printer
--
-- @tfield MapRecordPrinter mapRecord Printer
--
FlagActionHandler.mapRecordPrinter = nil


---
-- FlagActionHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn FlagActionHandler The FlagActionHandler instance
--
function FlagActionHandler:__construct(_parentGemaMode)

  local instance = BaseEventHandler(_parentGemaMode, "onFlagAction");
  setmetatable(instance, {__index = FlagActionHandler});

  return instance;

end

getmetatable(FlagActionHandler).__call = FlagActionHandler.__construct;


-- Public Methods

---
-- Event handler that is called when the state of the flag is changed.
--
-- @tparam int _cn The client number of the player who changed the state
-- @tparam int _action The id of the flag action
-- @tparam int _flag The id of the flag whose state was changed
--
function FlagActionHandler:handleEvent(_cn, _action, _flag)

  if (self.parentGemaMode:getIsActive()) then

    local player = self:getPlayerByCn(_cn)

    if (_action == FA_SCORE) then

      local scoreAttempt = player:getScoreAttempt();
      if (not scoreAttempt:isFinished()) then
        scoreAttempt:finish();
        self:registerRecord(scoreAttempt);
      end

    elseif (_action == FA_DROP or _action == FA_LOST) then
      -- instant flag reset (gameplay affecting)
      self:resetFlag(player, _flag);
    end

  end

end


-- Private Methods

---
-- Adds a record to the maptop and prints the score message.
--
-- @tparam PlayerScoreAttempt scoreAttempt The players score attempt
--
function FlagActionHandler:registerRecord(scoreAttempt)

  local mapTop = self.parentGemaMode:getMapTopHandler():getMapTop("main");
  local record = scoreAttempt:getMapRecord(mapTop:getMapRecordList());

  self.output:printTableTemplate("TableTemplate/MapRecord/MapRecordScore", { mapRecord = record });
  mapTop:addRecord(record);

end

---
-- Triggers the flag action "player <name> returned the flag".
--
-- @tparam int _player The player who dropped the flag
-- @tparam int _flag The flag id of the flag that was dropped
--
function FlagActionHandler:resetFlag(_player, _flag)
  flagaction(_player:getCn(), FA_RESET, _flag);
end


return FlagActionHandler;
