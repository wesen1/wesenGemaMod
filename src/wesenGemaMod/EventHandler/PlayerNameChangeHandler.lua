---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Class that handles player name changes.
--
-- @type PlayerNameChangeHandler
--
local PlayerNameChangeHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
--
-- @tfield GemaMod parentGemaMod
--
PlayerNameChangeHandler.parentGemaMod = "";


---
-- PlayerNameChangeHandler constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn PlayerNameChangeHandler The PlayerNameChangeHandler instance
--
function PlayerNameChangeHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerNameChangeHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;

end


-- Getters and setters

---
-- Returns the parent gema mod.
--
-- @treturn GemaMod The parent gema mod
--
function PlayerNameChangeHandler:getParentGemaMod()
  return self.parentGemaMod;
end

---
-- Sets the parent gema mod.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
function PlayerNameChangeHandler:setParentGemaMod(_parentGemaMod)
  self.parentGemaMod = _parentGemaMod;
end


-- Class Methods

---
-- Event handler which is called when a player changes his name.
-- Updates the player object and adds a data base entry for the new player ip/name combination.
--
-- @tparam int _cn The client number of the player who changed his name
-- @tparam string _newName The new name of the player
--
function PlayerNameChangeHandler:onPlayerNameChange (_cn, _newName)

  local dataBase = self.parentGemaMod:getDataBase();

  self.parentGemaMod:getPlayers()[_cn]:setName(_newName);
  self.parentGemaMod:getPlayers()[_cn]:savePlayer(dataBase);

end


return PlayerNameChangeHandler;
