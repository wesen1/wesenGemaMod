---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Loads player information to the database.
--
-- @type PlayerInformationLoader
--
local PlayerInformationLoader = {};


-- Class Methods

---
-- Fetches the ip id of a player ip from the database.
--
-- @tparam DataBase _dataBase The database
-- @tparam string _playerIp The player ip
--
-- @treturn int|nil The ip id or nil if the ip was not found in the database
--
function PlayerInformationLoader:fetchIpId(_dataBase, _playerIp)

  local sql = "SELECT id " ..
              "FROM ips " ..
              "WHERE ip='%s';";

  local result = _dataBase:query(string.format(sql, _playerIp), true);

  if (#result == 0) then
    return nil;
  else
    return tonumber(result[1].id);
  end

end

---
-- Fetches the id of this player name from the database.
--
-- @tparam DataBase _dataBase The database
-- @tparam string _playerName The player name
--
-- @treturn int|nil The player name id or nil if the player name was not found in the database
--
function PlayerInformationLoader:fetchNameId(_dataBase, _playerName)

  local sanitizedPlayerName = _dataBase:sanitize(_playerName);

  -- must use the keyword BINARY in order to make the string comparison case sensitve
  local sql = "SELECT id " ..
              "FROM names " ..
              "WHERE name=BINARY '%s';";

  local result = _dataBase:query(string.format(sql, sanitizedPlayerName), true);

  if (#result == 0) then
    return nil;
  else
    return tonumber(result[1]["id"]);
  end

end

---
-- Fetches the id of the player from the database.
-- Must be called after the saveName() and saveIp() were called.
--
-- @tparam DataBase _dataBase The database
-- @tparam Player _player The player
-- @tparam int|nil _nameId The name id
-- @tparma int|nil _ipId The ip id
--
-- @treturn int|nil The player id or nil if the player was not found in the database
--
function PlayerInformationLoader:fetchPlayerId(_dataBase, _player, _nameId, _ipId)

  local nameId = -1;
  if (_nameId == nil) then
    nameId = self:fetchNameId(_dataBase, _player:getName());
  else
    nameId = _nameId;
  end

  local ipId = -1;
  if (_ipId == nil) then
    ipId = self:fetchIpId(_dataBase, _player:getIp());
  else
    ipId = _ipId;
  end

  local sql = "SELECT id " ..
              "FROM players " ..
              "WHERE name=%d AND ip=%d;";

  local result = _dataBase:query(string.format(sql, nameId, ipId), true);

  if (#result == 0) then
    return nil;
  else
    return tonumber(result[1]["id"]);
  end

end


return PlayerInformationLoader;
