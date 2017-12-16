---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

require("Output");

--
-- Event handler which is called when a player calls a vote
--
function onPlayerCallVote(_cn, _type, _text, _number1, _number2, _voteError)

  if (_type == SA_MAP and
      _number1 == GM_CTF and
      _voteError == VOTEE_INVALID and
      mapexists(_text))
  then

    Map:removeMap(_text);
    
    local infoMessage = "The map was automatically deleted because it wasn't playable";
    Output:print(colorLoader:getColor("info") .. infoMessage, _cn);
    
  end

end