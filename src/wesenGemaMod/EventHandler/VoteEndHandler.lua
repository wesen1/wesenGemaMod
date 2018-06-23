---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local MapChecker = require("Maps/MapChecker");
local MapRotSwitcher = require("Maps/MapRot/MapRotSwitcher");
local Output = require("Outputs/Output");

---
-- Class that handles vote ends.
--
-- @type VoteEndHandler 
--
local VoteEndHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
--
-- @tfield GemaMod parentGemaMod
--
VoteEndHandler.parentGemaMod = "";


---
-- VoteEndHandler constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn VoteEndHandler The VoteEndHandler instance
--
function VoteEndHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = VoteEndHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;

end


-- Getters and setters

---
-- Returns the parent gema mod.
--
-- @treturn GemaMod The parent gema mod
--
function VoteEndHandler:getParentGemaMod()
  return self.parentGemaMod;
end

---
-- Sets the parent gema mod.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
function VoteEndHandler:setParentGemaMod(_parentGemaMod)
  self.parentGemaMod = _parentGemaMod;
end


-- Class Methods

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
function VoteEndHandler:onVoteEnd(_result, _cn, _type, _text, _number1, _number2)

  if (_result == 1) then
    -- Vote passed

    if (_type == SA_MAP) then

      if (self.parentGemaMod:getIsActive() and (_number1 ~= GM_CTF or not MapChecker:isGema(_text))) then
        MapRotSwitcher:switchToRegularMapRot();
        Output:print(Output:getColor("info") .. "[INFO] Regular maprot loaded.");
      elseif (not self.parentGemaMod:getIsActive() and _number1 == GM_CTF and MapChecker:isGema(_text)) then
        MapRotSwitcher:switchToGemaMapRot();
        Output:print(Output:getColor("info") .. "[INFO] Gema map rot loaded.");
      end

    end

  end

end


return VoteEndHandler;
