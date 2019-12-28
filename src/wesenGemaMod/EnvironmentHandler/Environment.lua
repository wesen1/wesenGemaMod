---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Stores information about the current and the next map and game mode.
--
-- @type Environment
--
local Environment = setmetatable({}, {});


---
-- The map name
--
-- @tfield string mapName
--
Environment.mapName = nil;

---
-- The game mode id
--
-- @tfield int gameModeId
--
Environment.gameModeId = nil;


---
-- Environment constructor.
--
-- @tparam string _mapName The map name
-- @tparam int _gameModeId The game mode id
--
-- @treturn Environment The Environment instance
--
function Environment:__construct(_mapName, _gameModeId)

  local instance = setmetatable({}, {__index = Environment});

  instance.mapName = _mapName;
  instance.gameModeId = _gameModeId;

  return instance;

end

getmetatable(Environment).__call = Environment.__construct;


-- Getters and Setters

---
-- Returns the map name.
--
-- @treturn string The map name
--
function Environment:getMapName()
  return self.mapName;
end

---
-- Sets the map name.
--
-- @tparam string _mapName The map name
--
function Environment:setMapName(_mapName)
  self.mapName = _mapName;
end

---
-- Returns the game mode id.
--
-- @treturn int The game mode id
--
function Environment:getGameModeId()
  return self.gameModeId;
end

---
-- Sets the game mode id.
--
-- @tparam int _gameModeId The game mode id
--
function Environment:setGameModeId(_gameModeId)
  self.gameModeId = _gameModeId;
end


return Environment;
