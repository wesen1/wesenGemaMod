---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local MapTopPrinter = require("Tops/MapTop/MapTopPrinter");
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
  instance.mapTopPrinter = MapTopPrinter(_output);
  
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

---
-- Returns the maptop printer.
--
-- @treturn MapTopPrinter The maptop printer
--
function MapTopHandler:getMapTopPrinter()
  return self.mapTopPrinter;
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


-- Public Methods

---
-- Prints a maptop to a player.
--
-- @tparam string _mapTopId The maptop id
-- @tparam Player _player The player to print the maptop to
--
-- @raise Error when the maptop id is invalid
--
function MapTopHandler:printMapTop(_mapTopId, _player)

  local mapTop = self:getMapTop(_mapTopId);
  
  if (mapTop) then
    self.mapTopPrinter:printMapTop(mapTop, _player);
  else
    error(Exception("No maptop with the id \"" .. _mapTopId .. "\" exists."));
  end

end


return MapTopHandler;
