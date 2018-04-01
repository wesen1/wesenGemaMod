---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Map = require("Maps/Map");
local MapChecker = require("Maps/MapChecker");
local Output = require("Outputs/Output");

---
-- Class that handles player vote calls.
--
-- @type PlayerCallVoteHandler
--
local PlayerCallVoteHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
--
-- @tfield GemaMod parentGemaMod
--
PlayerCallVoteHandler.parentGemaMod = "";


---
-- PlayerCallVoteHandler constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn PlayerCallVoteHandler The PlayerCallVoteHandler instance
--
function PlayerCallVoteHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerCallVoteHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;

end


-- Getters and setters

---
-- Returns the parent gema mod.
--
-- @treturn GemaMod The parent gema mod
--
function PlayerCallVoteHandler:getParentGemaMod()
  return self.parentGemaMod;
end

---
-- Sets the parent gema mod.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
function PlayerCallVoteHandler:setParentGemaMod(_parentGemaMod)
  self.parentGemaMod = _parentGemaMod;
end


-- Class Methods

---
-- Event handler which is called when a player calls a vote.
--
-- @tparam int _cn The client number of the player that called the vote
-- @tparam int _type The vote type
-- @tparam string _text The map name, kick reason, etc.
-- @tparam int _number1 The game mode, target cn, etc.
-- @tparam int _number2 The time of the map vote, target team of teamchange vote, etc.
-- @tparam int _voteError The vote error
--
-- @treturn int|nil PLUGIN_BLOCK if a voted map is auto removed or nil
--
function PlayerCallVoteHandler:onPlayerCallVote(_cn, _type, _text, _number1, _number2, _voteError)

  -- If vote is a map vote
  if (_type == SA_MAP) then

    -- If the map vote is invalid
    if (_voteError == VOTEE_INVALID) then

      if (mapexists(_text)) then
        Map:removeMap(self.parentGemaMod:getDataBase(),
                      _text,
                      self.parentGemaMod:getMapTop(),
                      self.parentGemaMod:getMapRotEditor()
        );

        local infoMessage = "The map \"" .. _text .. "\" was automatically deleted because it wasn't playable";
        Output:print(Output:getColor("info") .. infoMessage, _cn);
        return PLUGIN_BLOCK;

      else
        Output:print(Output:getColor("error") .. "The map \"" .. _text .. "\" could not be found on the server.", _cn);
      end

    elseif (_voteError == VOTEE_NOERROR) then

      if (self.parentGemaMod:getIsActive() and (_number1 ~= GM_CTF or not MapChecker:isGema(_text))) then
        Output:print(Output:getColor("info") .. "[INFO] The gema mode will be automatically disabled when this vote passes.");
      elseif (not self.parentGemaMod:getIsActive() and _number1 == GM_CTF and MapChecker:isGema(_text)) then
        Output:print(Output:getColor("info") .. "[INFO] The gema mode will be automatically enabled when this vote passes.");
      end

    end

  end

end


return PlayerCallVoteHandler;
