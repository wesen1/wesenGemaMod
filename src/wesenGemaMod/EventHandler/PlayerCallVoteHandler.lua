---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");
local PlayerCallMapVoteHandler = require("EventHandler/PlayerCallMapVoteHandler");

---
-- Class that handles player vote calls.
-- PlayerCallVoteHandler inherits from BaseEventHandler
--
-- @type PlayerCallVoteHandler
--
local PlayerCallVoteHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- PlayerCallVoteHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn PlayerCallVoteHandler The PlayerCallVoteHandler instance
--
function PlayerCallVoteHandler:__construct(_parentGemaMode)

  local instance = BaseEventHandler(_parentGemaMode);
  setmetatable(instance, {__index = PlayerCallVoteHandler});

  instance.playerCallMapVoteHandler = PlayerCallMapVoteHandler(_parentGemaMode);

  return instance;

end

getmetatable(PlayerCallVoteHandler).__call = PlayerCallVoteHandler.__construct;


-- Class Methods

---
-- Event handler which is called when a player calls a vote.
--
-- @tparam Player _player The player that called the vote
-- @tparam int _type The vote type
-- @tparam string _text The map name, kick reason, etc.
-- @tparam int _number1 The game mode, target cn, etc.
-- @tparam int _number2 The time of the map vote, target team of teamchange vote, etc.
-- @tparam int _voteError The vote error
--
-- @treturn int|nil PLUGIN_BLOCK if a voted map is auto removed or nil
--
function PlayerCallVoteHandler:handleEvent(_player, _type, _text, _number1, _number2, _voteError)

  -- If vote is a map vote
  if (_type == SA_MAP) then
    return self.playerCallMapVoteHandler:handleEvent(_player, _text, _number1, _number2, _voteError);
  end

end


return PlayerCallVoteHandler;
