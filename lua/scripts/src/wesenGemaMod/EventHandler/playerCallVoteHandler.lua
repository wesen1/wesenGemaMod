---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- 

local Map = require("Maps/Map");
local Output = require("Outputs/Output");

---
-- Class that handles player vote calls.
--
local PlayerCallVoteHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
-- 
-- @param GemaMod parentGemaMod
-- 
PlayerCallVoteHandler.parentGemaMod = "";


---
-- PlayerCallVoteHandler constructor.
-- 
-- @param GemaMod _parentGemaMod The parent gema mod
--
function PlayerCallVoteHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerCallVoteHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;
  
end


---
-- Event handler which is called when a player calls a vote
--
function PlayerCallVoteHandler:onPlayerCallVote(_cn, _type, _text, _number1, _number2, _voteError)

  if (_type == SA_MAP and
      _number1 == GM_CTF and
      _voteError == VOTEE_INVALID and
      mapexists(_text))
  then

    Map:removeMap(self.parentGemaMod:getDataBase(), _text, self.parentGemaMod:getMapTop());

    local infoMessage = "The map was automatically deleted because it wasn't playable";
    Output:print(Output:getColor("info") .. infoMessage, _cn);
    
    return PLUGIN_BLOCK;
    
  end

end


return PlayerCallVoteHandler;
