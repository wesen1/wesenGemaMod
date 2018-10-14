---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local CachedMapRot = require("MapRot/CachedMapRot");
local Environment = require("EnvironmentHandler/Environment");
local SavedMapRot = require("MapRot/SavedMapRot");

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
-- MapRot constructor.
--
-- @treturn MapRot The MapRot instance
--
function MapRot:__construct(_mapRotFilePath)

  local instance = setmetatable({}, { __index = MapRot });

  instance.cachedMapRot = CachedMapRot();
  instance.savedMapRot = SavedMapRot(_mapRotFilePath);
  instance.cachedMapRot:load(instance.savedMapRot);
  
  return instance;

end

getmetatable(MapRot).__call = MapRot.__construct;


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
end

--
-- Sets the saved maprot to maprot.cfg.
--
function MapRot:switchToRegularMapRot()
  self.savedMapRot:setFilePath("config/maprot.cfg");
end

---
-- Switches to the gema map rot and loads it into the cached map rot.
--
function MapRot:loadGemaMapRot()
  self:switchToGemaMapRot();
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
