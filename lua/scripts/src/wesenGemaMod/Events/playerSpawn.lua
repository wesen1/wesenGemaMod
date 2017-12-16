---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

---
-- Event handler which is called when a player spawns.
-- Initializes the start time of the player that spawned
--
-- @param _cn (int) The client number of the player
--
function onPlayerSpawn(_cn)

  players[_cn]:setStartTime(getsvtick());

end