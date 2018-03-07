---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- 

---
-- Class that handles player name changes.
--
local PlayerNameChangeHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
-- 
-- @param GemaMod parentGemaMod
-- 
PlayerNameChangeHandler.parentGemaMod = "";


---
-- PlayerNameChangeHandler constructor.
-- 
-- @param GemaMod _parentGemaMod The parent gema mod
--
function PlayerNameChangeHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = PlayerNameChangeHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;
  
end

---
-- Event handler which is called when a player changes his name.
-- Updates the player object and adds a data base entry for the new player ip/name combination.
--
-- @param _cn (int) The client number of the player
-- @param _newName (String) The new name of the player
--
function PlayerNameChangeHandler:onPlayerNameChange (_cn, _newName)

  local dataBase = self.parentGemaMod:getDataBase();

  self.parentGemaMod:getPlayers()[_cn]:setName(_newName);
  self.parentGemaMod:getPlayers()[_cn]:savePlayerData(dataBase);

end


return PlayerNameChangeHandler;
