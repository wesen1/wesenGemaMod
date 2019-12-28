---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Environment = require("EnvironmentHandler/Environment");
local MapRotGenerator = require("MapRot/MapRotGenerator");
local StaticString = require("Output/StaticString");

---
-- Represents the loaded maprot and the maprot config file.
--
-- @type MapRot
--
local MapRot = setmetatable({}, {});


---
-- The map rot generator
--
-- @tfield MapRotGenerator mapRotGenerator
--
MapRot.mapRotGenerator = nil;

---
-- The type of the map rot
-- This is either "gema" or "regular"
--
-- @tfield string type
--
MapRot.type = nil;


---
-- MapRot constructor.
--
-- @treturn MapRot The MapRot instance
--
function MapRot:__construct()

  local instance = setmetatable({}, { __index = MapRot });

  instance.mapRotGenerator = MapRotGenerator();
  instance.type = nil;

  return instance;

end

getmetatable(MapRot).__call = MapRot.__construct;


-- Getters and Setters

---
-- Returns the current type of the map rot.
--
-- @treturn string The current type of the map rot
--
function MapRot:getType()
  return self.type
end


-- Public Methods

--
-- Sets the saved maprot to maprot_gema.cfg.
--
function MapRot:switchToGemaMapRot()
  self.savedMapRot:setFilePath("config/maprot_gema.cfg");
  self.type = StaticString("mapRotTypeGema"):getString();
end

--
-- Sets the saved maprot to maprot.cfg.
--
function MapRot:switchToRegularMapRot()
  self.savedMapRot:setFilePath("config/maprot.cfg");
  self.type = StaticString("mapRotTypeRegular"):getString();
end

---
-- Switches to the gema map rot and loads it into the cached map rot.
--
function MapRot:loadGemaMapRot()
  self:switchToGemaMapRot();
  self.mapRotGenerator:generateGemaMapRot(self, "packages/maps/servermaps/incoming");
  self.cachedMapRot:load(self.savedMapRot);
end

---
-- Switches to the regular map rot and loads it into the cached map rot.
--
function MapRot:loadRegularMapRot()
  self:switchToRegularMapRot();
  self.cachedMapRot:load(self.savedMapRot);
end


return MapRot;
