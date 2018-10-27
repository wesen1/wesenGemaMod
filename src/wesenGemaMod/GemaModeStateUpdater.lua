---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Handles updating the gema modes state.
--
local GemaModeStateUpdater = setmetatable({}, {});


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

  instance.parentGemaMode = _parentGemaMode;

  return instance;

end

getmetatable(GemaModeStateUpdater).__call = GemaModeStateUpdater.__construct;


-- Public Methods

---
-- Sets the next environment.
--
function GemaModeStateUpdater:setNextEnvironment(_nextEnvironment)
  local environmentHandler = self.parentGemaMode:getEnvironmentHandler();
  environmentHandler:setNextEnvironment(_nextEnvironment);
end

---
-- Resets the next environment back to the maprots next environment.
--
function GemaModeStateUpdater:resetNextEnvironment()
  local environmentHandler = self.parentGemaMode:getEnvironmentHandler();
  environmentHandler:setNextEnvironment(self.mapRot:getNextEnvironment());
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

  local environmentHandler = self.parentGemaMode:getEnvironmentHandler();
  local mapRot = self.parentGemaMode:getMapRot();
  environmentHandler:switchToNextEnvironment(mapRot);

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

  local environmentHandler = self.parentGemaMode:getEnvironmentHandler();
  local isNextEnvironmentGemaCompatible = environmentHandler:isNextEnvironmentGemaCompatible();

  if (self.parentGemaMode:getIsActive() and not isNextEnvironmentGemaCompatible) then
    nextGemaModeState = false;
  elseif (not self.parentGemaMode:getIsActive() and isNextEnvironmentGemaCompatible) then
    nextGemaModeState = true;
  end

  return nextGemaModeState;

end


return GemaModeStateUpdater;
