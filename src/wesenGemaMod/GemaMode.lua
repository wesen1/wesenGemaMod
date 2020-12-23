---
-- @author wesen
-- @copyright 2018-2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseGameMode = require "AC-LuaServer.Extensions.GameModeManager.BaseGameMode"
local ClientOutputFactory = require("AC-ClientOutput/ClientOutputFactory")
local ColorLoader = require("Output/Util/ColorLoader")
local EventHandler = require("EventHandler");
local MapNameChecker = require("Map/MapNameChecker");
local MapRot = require("MapRot/MapRot");
local MapTopHandler = require("Tops/MapTopHandler");
local Output = require("Output/Output");
local PlayerList = require("Player/PlayerList");
local TemplateFactory = require("Output/Template/TemplateFactory")
local TimeFormatter = require("TimeHandler/TimeFormatter")

---
-- Wrapper class for the gema mode.
--
-- @type GemaMode
--
local GemaMode = BaseGameMode:extend()

---
-- The event handler
--
-- @tfield EventHandler eventHandler
--
GemaMode.eventHandler = nil;

---
-- The map name checker
--
-- @tfield MapNameChecker mapNameChecker
--
GemaMode.mapNameChecker = nil;

---
-- The map top handler
--
-- @tfield MapTopHandler mapTopHandler
--
GemaMode.mapTopHandler = nil;

---
-- The map rot
--
-- @tfield MapRot mapRot
--
GemaMode.mapRot = nil;

---
-- The output
--
-- @tfield Output output
--
GemaMode.output = nil;

---
-- The player list
--
-- @tfield PlayerList playerList
--
GemaMode.playerList = nil;


---
-- GemaMode constructor.
--
function GemaMode:new()

  self.super.new(self, "GemaGameMode", "Gema")

  self.eventHandler = EventHandler()
  self.mapNameChecker = MapNameChecker()
  self.mapRot = MapRot()
  self.mapTopHandler = MapTopHandler()

  self.output = Output()
  self.playerList = PlayerList()

end


-- Getters and setters

---
-- Returns the map rot.
--
-- @treturn MapRot The map rot
--
function GemaMode:getMapRot()
  return self.mapRot;
end

---
-- Returns the map top handler.
--
-- @treturn MapTop The map top handler
--
function GemaMode:getMapTopHandler()
  return self.mapTopHandler;
end

---
-- Returns the output.
--
-- @treturn Output The output
--
function GemaMode:getOutput()
  return self.output;
end

---
-- Returns the player list.
--
-- @treturn PlayerList The player list
--
function GemaMode:getPlayerList()
  return self.playerList;
end


-- Public Methods

---
-- Returns whether this GameMode can be enabled for a specified Game.
--
-- @tparam Game _game The game to check
--
-- @treturn bool True if this GameMode can be enabled for the specified Game, false otherwise
--
function GemaMode:canBeEnabledForGame(_game)
  return (_game:getGameModeId() == GM_CTF and self.mapNameChecker:isGemaMapName(_game:getMapName()))
end

---
-- Loads the commands and generates the gema maprot.
--
function GemaMode:initialize()

  self:parseConfig()
  self.mapTopHandler:initialize();

  self.eventHandler:loadEventHandlers(self, "lua/scripts/wesenGemaMod/EventHandler")
  self.eventHandler:initializeEventListeners()

end

function GemaMode:terminate()
end

---
-- Parses the gema mode config.
--
function GemaMode:parseConfig()

  local config = cfg.totable("gemamod")

  local colorConfigurationFileName = "colors"
  ClientOutputFactory.getInstance():configure({
      fontConfigFileName = "FontDefault",
      defaultConfiguration = config
  })

  TemplateFactory.getInstance():configure({
    templateRenderer = {
      defaultTemplateValues = {
        colors = ColorLoader(colorConfigurationFileName):getColors(),
        timeFormatter = TimeFormatter()
      },
      basePath = "lua/config/templates",
      suffix = ".template"
    }
  })

end


return GemaMode
