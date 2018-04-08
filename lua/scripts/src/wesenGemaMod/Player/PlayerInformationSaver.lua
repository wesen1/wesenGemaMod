---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local PlayerInformationLoader = require("Player/PlayerInformationLoader");

---
-- Saves player information to the database.
--
-- @type PlayerSaver
--
local PlayerInformationSaver = {};


-- Class Methods

---
-- Saves the player ip to the database.
--
-- @tparam DataBase _dataBase The database
--
function PlayerInformationSaver:saveIp(_dataBase, _playerIp)

  local sql = "INSERT INTO ips " ..
              "(ip) " ..
              "VALUES ('%s');";

  _dataBase:query(string.format(sql, _ip), false);

end

---
-- Saves the player name to the database.
--
-- @tparam DataBase _dataBase The database
--
function PlayerInformationSaver:saveName(_dataBase, _playerName)

  local sanitizedPlayerName = _dataBase:sanitize(_playerName);
  local sql = "INSERT INTO names " ..
              "(name) " ..
              "VALUES ('%s');";

  _dataBase:query(string.format(sql, sanitizedPlayerName), false);

end

---
-- Saves the player (combination of ip and name) in the database.
--
-- @tparam DataBase _dataBase The database
-- @tparam Player _player The player
--
function PlayerInformationSaver:savePlayer(_dataBase, _player)

  local nameId = PlayerInformationLoader:fetchNameId(_dataBase, _player:getName());
  if (nameId == nil) then
    self:saveName(_dataBase, _player:getName());
    nameId = PlayerInformationLoader:fetchNameId(_dataBase, _player:getName());
  end

  local ipId = PlayerInformationLoader:fetchIpId(_dataBase, _player:getIp());
  if (ipId == nil) then
    self:saveIp(_dataBase, ipId, _player:getIp());
    ipId = PlayerInformationLoader:fetchIpId(_dataBase, _player:getIp());
  end

  local playerId = PlayerInformationLoader:fetchPlayerId(_dataBase, _player, nameId, ipId);
  if (playerId == nil) then

    local sql = "INSERT INTO players " ..
                "(name, ip) " ..
                "VALUES (%d,%d);";
    _dataBase:query(string.format(sql, nameId, ipId), false);

  end

end


return PlayerInformationSaver;
