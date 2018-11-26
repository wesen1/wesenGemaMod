---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local lfs = require("lfs");
local MapNameChecker = require("Map/MapNameChecker");

---
-- Generates maprots from the existing maps.
--
-- @type MapRotGenerator
--
local MapRotGenerator = setmetatable({}, {});

---
-- The map name checker
--
-- @tfield MapNameChecker mapNameChecker
--
MapRotGenerator.mapNameChecker = nil;


---
-- MapRotGenerator constructor.
--
-- @treturn MapRotGenerator The MapRotGenerator instance
--
function MapRotGenerator:__construct()

  local instance = setmetatable({}, {__index = MapRotGenerator});

  instance.mapNameChecker = MapNameChecker();

  return instance;

end

getmetatable(MapRotGenerator).__call = MapRotGenerator.__construct;


-- Public Methods

---
-- Generates a gema map rot from the existing gema server maps.
--
-- @tparam MapRot _mapRot The map rot to which the map entries will be added
-- @tparam string _mapsDirectory The path to the maps directory
--
function MapRotGenerator:generateGemaMapRot(_mapRot, _mapsDirectory)

  _mapRot:clear();

  for luaFile in lfs.dir(_mapsDirectory) do

    -- If the file ends with ".cgz"
    if (luaFile:match("^.+%.cgz$")) then

      local mapName = luaFile:gsub(".cgz", "");

      if (not self.mapNameChecker:isValidMapName(mapName)) then
        os.remove(_mapsDirectory .. "/" .. luaFile);
      elseif (self.mapNameChecker:isGemaMapName(mapName)) then
        _mapRot:addMap(mapName);
      end

    end

  end

end


return MapRotGenerator;
