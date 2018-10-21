---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local MapNameChecker = require("Map/MapNameChecker");

---
-- Stores the current and next environments for analyzation.
--
-- @type EnvironmentHandler
--
local EnvironmentHandler = setmetatable({}, {});


---
-- The current environment
--
-- @tfield Environment currentEnvironment
--
EnvironmentHandler.currentEnvironment = nil;

---
-- The next environment
--
-- @tfield Environment nextEnvironment
--
EnvironmentHandler.nextEnvironment = nil;

---
-- The map name checker
--
-- @tfield MapNameChecker mapNameChecker
--
EnvironmentHandler.mapNameChecker = nil;


---
-- EnvironmentHandler constructor.
--
-- @treturn EnvironmentHandler The EnvironmentHandler instance
--
function EnvironmentHandler:__construct(_mapRot)

  local instance = setmetatable({}, {__index = EnvironmentHandler});

  instance.mapNameChecker = MapNameChecker();
  instance.nextEnvironment = _mapRot:getNextEnvironment();

  return instance;

end

getmetatable(EnvironmentHandler).__call = EnvironmentHandler.__construct;


-- Getters and Setters

---
-- Returns the current environment.
--
-- @treturn Environment The current environment
--
function EnvironmentHandler:getCurrentEnvironment()
  return self.currentEnvironment;
end

---
-- Sets the current environment.
--
-- @tparam Environment _currentEnvironment The current environment
--
function EnvironmentHandler:setCurrentEnvironment(_currentEnvironment)
  self.currentEnvironment = _currentEnvironment;
end

---
-- Returns the next environment.
--
-- @treturn Environment The next environment
--
function EnvironmentHandler:getNextEnvironment()
  return self.nextEnvironment;
end

---
-- Sets the next environment.
--
-- @tparam Environment _nextEnvironment The next environment
--
function EnvironmentHandler:setNextEnvironment(_nextEnvironment)
  self.nextEnvironment = _nextEnvironment;
end


-- Public Methods

---
-- Updates the currentEnvironment and nextEnvironment variables.
--
-- @tparam MapRot The current maprot
--
function EnvironmentHandler:switchToNextEnvironment(_mapRot)
  self.currentEnvironment = self.nextEnvironment;
  self.nextEnvironment = _mapRot:getNextEnvironment();
end

---
-- Returns whether the current environment is gema compatible.
--
-- @treturn bool True if the current environment is gema compatible, false otherwise
--
function EnvironmentHandler:isCurrentEnvironmentGemaCompatible()
  return self:isEnvironmentGemaCompatible(self.currentEnvironment);
end

---
-- Returns whether the next environment is gema compatible.
--
-- @treturn bool True if the next environment is gema compatible, false otherwise
--
function EnvironmentHandler:isNextEnvironmentGemaCompatible()
  return self:isEnvironmentGemaCompatible(self.nextEnvironment);
end


-- Private Methods

---
-- Returns whether an environment is gema compatible.
-- The map name must be a gema map name and the game mode must be CTF, otherwise the gema mode can not be active.
--
-- @treturn bool True if the environment is gema compatible, false otherwise
--
function EnvironmentHandler:isEnvironmentGemaCompatible(_environment)

  if (_environment.gameModeId == GM_CTF and self.mapNameChecker:isGemaMapName(_environment.mapName)) then
    return true;
  else
    return false;
  end

end


return EnvironmentHandler;
