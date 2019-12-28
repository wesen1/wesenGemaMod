---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local CachedMapRot = require("MapRot/CachedMapRot");
local Environment = require("EnvironmentHandler/Environment");
local MapRotGenerator = require("MapRot/MapRotGenerator");
local SavedMapRot = require("MapRot/SavedMapRot");
local StaticString = require("Output/StaticString");

---
-- Represents the loaded maprot and the maprot config file.
--
-- @type MapRot
--
local MapRot = setmetatable({}, {});


---
-- The cached maprot
--
-- @tfield CachedMapRot cachedMapRot
--
MapRot.cachedMapRot = nil;

---
-- The saved maprot
--
-- @tfield SavedMapRot savedMapRot
--
MapRot.savedMapRot = nil;

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

  instance.cachedMapRot = CachedMapRot();
  instance.savedMapRot = SavedMapRot();

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

---
-- Returns the next environment.
--
-- @treturn Environment The next environment
--
function MapRot:getNextEnvironment()
  local nextMapRotEntry = self.cachedMapRot:getNextEntry();
  return Environment(nextMapRotEntry["map"], nextMapRotEntry["mode"]);
end

---
-- Adds a map to the cached and saved maprot.
--
-- @tparam string _mapName The map name
--
function MapRot:addMap(_mapName)
  self.cachedMapRot:addMap(_mapName);
  self.savedMapRot:addMap(_mapName);
end

---
-- Removes a map from the cached and saved maprot.
--
-- @tparam string _mapName The map name
--
function MapRot:removeMap(_mapName)
  self.cachedMapRot:removeMap(_mapName);
  self.savedMapRot:removeMap(_mapName);
end

---
-- Clears the cached and saved map rot.
--
function MapRot:clear()
  self.cachedMapRot:clear();
  self.savedMapRot:remove();
end

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
