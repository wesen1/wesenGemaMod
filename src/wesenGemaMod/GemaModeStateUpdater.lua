---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EnvironmentHandler = require("EnvironmentHandler/EnvironmentHandler");

---
-- Handles updating the gema modes state.
--
local GemaModeStateUpdater = setmetatable({}, {});


---
-- The environment handler
--
-- @tfield EnvironmentHandler environmentHandler
--
GemaModeStateUpdater.environmentHandler = nil;

---
-- The map rot
--
-- @tfield MapRot mapRot
--
GemaModeStateUpdater.mapRot = nil;

---
-- The parent gema mode
--
-- @tfield GemaMode parentGemaMode
--
GemaModeStateUpdater.parentGemaMode = nil;


---
-- GemaModeStateUpdater constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn GemaModeStateUpdater The GemaModeStateUpdater instance
--
function GemaModeStateUpdater:__construct(_parentGemaMode)

  local instance = setmetatable({}, {__index = GemaModeStateUpdater});

  instance.mapRot = _parentGemaMode:getMapRot();
  instance.environmentHandler = EnvironmentHandler(_parentGemaMode:getMapRot());
  instance.parentGemaMode = _parentGemaMode;

  return instance;

end

getmetatable(GemaModeStateUpdater).__call = GemaModeStateUpdater.__construct;


-- Public Methods

---
-- Sets the next environment.
--
function GemaModeStateUpdater:setNextEnvironment(_nextEnvironment)
  self.environmentHandler:setNextEnvironment(_nextEnvironment);
end

---
-- Resets the next environment back to the maprots next environment.
--
function GemaModeStateUpdater:resetNextEnvironment()
  self.environmentHandler:setNextEnvironment(self.mapRot:getNextEnvironment());
end

---
-- Switches to the next environment.
--
-- @treturn bool|nil The new gema mode state or nil if the gema mode state doesn't change
--
function GemaModeStateUpdater:switchToNextEnvironment()

  local nextGemaModeStateUpdate = self:getNextGemaModeStateUpdate();

  if (nextGemaModeStateUpdate ~= nil) then
    self.parentGemaMode:setIsActive(nextGemaModeStateUpdate);
    --@todo: Update server name
  end

  self.environmentHandler:switchToNextEnvironment(self.mapRot);

  return nextGemaModeStateUpdate;

end

---
-- Returns the updated gema mode state for the next map or nil if the gema mode state doesn't change.
--
-- @treturn bool|nil The updated gema mode state or nil if the gema mode doesn't change
--
function GemaModeStateUpdater:getNextGemaModeStateUpdate()

  local nextGemaModeState = self:getNextGemaModeState();

  if (nextGemaModeState ~= self.parentGemaMode:getIsActive()) then
    return nextGemaModeState;
  end

end


-- Private Methods

---
-- Returns the gema mode state for the next environment.
--
-- @treturn bool True if the gema mode is active in the next environment, false otherwise
--
function GemaModeStateUpdater:getNextGemaModeState()

  local nextGemaModeState = self.parentGemaMode:getIsActive();

  local isNextEnvironmentGemaCompatible = self.environmentHandler:isNextEnvironmentGemaCompatible();
  if (self.parentGemaMode:getIsActive() and not isNextEnvironmentGemaCompatible) then
    nextGemaModeState = false;
  elseif (not self.parentGemaMode:getIsActive() and isNextEnvironmentGemaCompatible) then
    nextGemaModeState = true;
  end

  return nextGemaModeState;

end


return GemaModeStateUpdater;
