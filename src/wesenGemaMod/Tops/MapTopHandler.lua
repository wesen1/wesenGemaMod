---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require("Util/Exception");
local MapTop = require("Tops/MapTop/MapTop");

---
-- Handles the maptops.
--
-- @type MapTopHandler
--
local MapTopHandler = setmetatable({}, {});

---
-- The list of map tops
--
-- @tfield MapTop[] mapTops
--
MapTopHandler.mapTops = nil;

---
-- The map top printer
--
-- @tfield MapTopPrinter mapTopPrinter
--
MapTopHandler.mapTopPrinter = nil;


---
-- MapTopHandler constructor.
--
-- @tparam Output _output The output
--
-- @treturn MapTopHandler The MapTopHandler instance
--
function MapTopHandler:__construct(_output)

  local instance = setmetatable({}, {__index = MapTopHandler});

  instance.mapTops = {};

  return instance;

end

getmetatable(MapTopHandler).__call = MapTopHandler.__construct;


-- Getters and Setters

---
-- Returns the list of maptops.
--
-- @treturn MapTop[] The list of maptops
--
function MapTopHandler:getMapTops()
  return self.mapTops;
end


-- Public Methods

---
-- Initializes the main maptop.
--
function MapTopHandler:initialize()
  self.mapTops["main"] = MapTop();
end

---
-- Returns a maptop with a specific id from the list of maptops.
--
-- @tparam string _mapTopId The maptop id
--
function MapTopHandler:getMapTop(_mapTopId)
  return self.mapTops[_mapTopId];
end


return MapTopHandler;
