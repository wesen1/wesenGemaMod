---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local MapTop = require("Tops/MapTop/MapTop");
local Server = require "AC-LuaServer.Core.Server"

---
-- Handles the maptops.
--
-- @type MapTopHandler
--
local MapTopHandler = setmetatable({}, {});

---
-- The EventCallback for the "onGameModeStaysEnabledAfterGameChange" event of the GameHandler
--
-- @tfield EventCallback onGameModeStaysEnabledAfterGameChangeEventCallback
--
MapTopHandler.onGameModeStaysEnabledAfterGameChangeEventCallback = nil

---
-- The list of map tops
--
-- @tfield MapTop[] mapTops
--
MapTopHandler.mapTops = nil;


---
-- MapTopHandler constructor.
--
-- @tparam Output _output The output
--
-- @treturn MapTopHandler The MapTopHandler instance
--
function MapTopHandler:__construct(_output)

  local instance = setmetatable({}, {__index = MapTopHandler});

  instance.onGameModeStaysEnabledAfterGameChangeEventCallback = EventCallback({ object = self, methodName = "onGameModeStaysEnabledAfterGameChange"})
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
-- Initializes the main maptop and the event listeners.
--
function MapTopHandler:initialize()
  self.mapTops["main"] = MapTop();

  local gameHandler = Server.getInstance():getGameHandler()
  gameHandler:on("onGameModeStaysEnabledAfterGameChange", self.onGameModeStaysEnabledAfterGameChangeEventCallback)

end

---
-- Removes the event listeners.
--
function MapTopHandler:terminate()

  local gameHandler = Server.getInstance():getGameHandler()
  gameHandler:off("onGameModeStaysEnabledAfterGameChange", self.onGameModeStaysEnabledAfterGameChangeEventCallback)

end

---
-- Returns a maptop with a specific id from the list of maptops.
--
-- @tparam string _mapTopId The maptop id
--
function MapTopHandler:getMapTop(_mapTopId)
  return self.mapTops[_mapTopId];
end


-- Event Handlers

---
-- Event handler which is called when the game mode is not changed after a Game change.
--
-- @tparam Game _game The new current Game
--
function MapTopHandler:onGameModeStaysEnabledAfterGameChange(_game)
  self.mapTops["main"]:loadRecords(_game:getMapName())
end


return MapTopHandler;
