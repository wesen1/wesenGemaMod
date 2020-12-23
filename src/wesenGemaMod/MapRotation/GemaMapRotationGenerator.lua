---
-- @author wesen
-- @copyright 2018-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local lfs = require "lfs"
local MapNameChecker = require "Map.MapNameChecker"
local Object = require "classic"

---
-- Generates gema maprots from the existing maps.
--
-- @type GemaMapRotationGenerator
--
local GemaMapRotationGenerator = Object:extend()

---
-- The map name checker
--
-- @tfield MapNameChecker mapNameChecker
--
GemaMapRotationGenerator.mapNameChecker = nil


---
-- GemaMapRotationGenerator constructor.
--
function GemaMapRotationGenerator:new()
  self.mapNameChecker = MapNameChecker()
end


-- Public Methods

---
-- Generates a gema map rot from the existing gema server maps.
--
-- @tparam MapRot _mapRot The map rot to which the map entries will be added
-- @tparam string _mapsDirectory The path to the maps directory
--
function GemaMapRotationGenerator:generateGemaMapRot(_mapRot, _mapsDirectory)

  _mapRot:clear();

  for luaFile in lfs.dir(_mapsDirectory) do

    -- If the file ends with ".cgz"
    if (luaFile:match("^.+%.cgz$")) then

      local mapName = luaFile:gsub(".cgz", "");

      if (not self.mapNameChecker:isValidMapName(mapName)) then
        os.remove(_mapsDirectory .. "/" .. luaFile);
      elseif (self.mapNameChecker:isGemaMapName(mapName)) then
        _mapRot::appendEntry(MapRotationEntry(mapName))
      end

    end

  end

end


return GemaMapRotationGenerator
