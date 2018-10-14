---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

--@todo: Replace this by ORM class!

---
-- Provides functions to load and save maps.
--
-- @type MapHandler
--
local MapHandler = setmetatable({}, {});


-- Class Methods

---
-- Fetches the map id from the database.
--
-- @tparam DataBase _dataBase The database
-- @tparam string _mapName The map name
--
-- @treturn int|nil The map id or nil if the map id was not found
--
function MapHandler:fetchMapId(_dataBase, _mapName)

  local mapName = _dataBase:sanitize(_mapName);

  local sql = "SELECT id "
           .. "FROM maps "
           .. "WHERE name = BINARY '" .. mapName .. "';";

  local result = _dataBase:query(sql, true);

  if (#result == 0) then
    return nil;
  else
    return tonumber(result[1].id);
  end

end

---
-- Saves the map name to the database.
--
-- @tparam DataBase _dataBase The database
-- @tparam string _mapName The map name
-- @tparam Player _uploadPlayer The upload player (may be nil)
--
function MapHandler:saveMapName(_dataBase, _mapName, _uploadPlayer)

  local mapName = _dataBase:sanitize(_mapName);
  
  local uploadPlayerId = "NULL";
  if (_uploadPlayer) then
    uploadPlayerId = _uploadPlayer:getId();
  end

  if (self:fetchMapId(_dataBase, _mapName) == nil) then

    local sql = "INSERT INTO maps "
             .. "(name, upload_player, uploaded_at) "
             .. "VALUES ('" .. mapName .. "', "
                            .. uploadPlayerId .. ", "
                            .. "FROM_UNIXTIME(" .. os.time() .. ")"
                     .. ");";

    _dataBase:query(sql, false);

  end

end


return MapHandler;
