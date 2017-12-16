---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

---
-- Event handler which is called when a player changes his name.
-- Updates the player object and adds a data base entry for the new player ip/name combination.
--
-- @param _cn (int) Client number of the player
-- @param _newName (String) The new name of the player
--
function onPlayerNameChange (_cn, _newName)

  players[_cn]:setName(_newName);
  players[_cn]:savePlayerData();

end