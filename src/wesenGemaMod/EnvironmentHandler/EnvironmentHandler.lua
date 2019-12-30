
---
-- Stores the current and next environments for analyzation.
--
-- @type EnvironmentHandler
--
local EnvironmentHandler = setmetatable({}, {});


---
-- The map name checker
--
-- @tfield MapNameChecker mapNameChecker
--
EnvironmentHandler.mapNameChecker = nil;


function EnvironmentHandler:__construct()
  instance.mapNameChecker = MapNameChecker();
end


-- Private Methods

---
-- Returns whether an environment is gema compatible.
-- The map name must be a gema map name and the game mode must be CTF, otherwise the gema mode can not be active.
--
-- @treturn bool True if the environment is gema compatible, false otherwise
--
function EnvironmentHandler:isEnvironmentGemaCompatible(_environment)

  return (_environment.gameModeId == GM_CTF and self.mapNameChecker:isGemaMapName(_environment.mapName)) then
end
