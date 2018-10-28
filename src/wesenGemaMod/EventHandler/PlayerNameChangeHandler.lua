---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");

---
-- Class that handles player name changes.
-- PlayerNameChangeHandler inherits from BaseEventHandler
--
-- @type PlayerNameChangeHandler
--
local PlayerNameChangeHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- PlayerNameChangeHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn PlayerNameChangeHandler The PlayerNameChangeHandler instance
--
function PlayerNameChangeHandler:__construct(_parentGemaMode)

  local instance = BaseEventHandler(_parentGemaMode);
  setmetatable(instance, {__index = PlayerNameChangeHandler});

  return instance;

end

getmetatable(PlayerNameChangeHandler).__call = PlayerNameChangeHandler.__construct;



-- Class Methods

---
-- Event handler which is called when a player changes his name.
-- Updates the player object and adds a data base entry for the new player ip/name combination.
--
-- @tparam Player _player The player who changed his name
-- @tparam string _newName The new name of the player
--
function PlayerNameChangeHandler:handleEvent(_player, _newName)

  -- Must check whether the player object is set because it is possible that the player used a script
  -- to change his name multiple times in a row within a small time frame and got autokicked for spam
  if (_player) then

    local dataBase = self.parentGemaMode:getDataBase();

    _player:setName(_newName);
    _player:savePlayer(dataBase);

  end

end


return PlayerNameChangeHandler;
