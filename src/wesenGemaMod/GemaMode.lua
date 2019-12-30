---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ClientOutputFactory = require("AC-ClientOutput/ClientOutputFactory")
local ColorLoader = require("Output/Util/ColorLoader")
local CommandLoader = require("CommandHandler/CommandLoader");
local EnvironmentHandler = require("EnvironmentHandler/EnvironmentHandler");
local EventHandler = require("EventHandler");
local GemaModeStateUpdater = require("GemaModeStateUpdater");
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
local GemaMode = setmetatable({}, {});

---
-- The command list
--
-- @tfield CommandList commandList
--
GemaMode.commandList = nil;

---
-- The command loader
--
-- @tfield CommandLoader commandLoader
--
GemaMode.commandLoader = nil;

---
-- The environment handler
--
-- @tfield EnvironmentHandler environmentHandler
--
GemaMode.environmentHandler = nil;

---
-- The event handler
--
-- @tfield EventHandler eventHandler
--
GemaMode.eventHandler = nil;

---
-- The gema mode state updater
--
-- @tfield GemaModeStateUpdater gemaModeStateUpdater
--
GemaMode.gemaModeStateUpdater = nil;

---
-- The map top handler
--
-- @tfield MapTopHandler mapTopHandler
--
GemaMode.mapTopHandler = nil;

---
-- The output
--
-- @tfield Output output
--
GemaMode.output = nil;

---
-- Indicates whether the gema mode is currently active
--
-- @tfield bool isActive
--
GemaMode.isActive = nil;


---
-- GemaMode constructor.
--
-- @treturn GemaMode The GemaMode instance
--
function GemaMode:__construct()

  local instance = setmetatable({}, {__index = GemaMode});

  instance.commandLoader = CommandLoader();
  instance.environmentHandler = EnvironmentHandler();
  instance.eventHandler = EventHandler();
  instance.gemaModeStateUpdater = GemaModeStateUpdater(instance);
  instance.mapRot = MapRot();
  instance.output = Output();
  instance.playerList = PlayerList();

  -- Must be created after the output was created
  instance.mapTopHandler = MapTopHandler(instance.output);

  instance.isActive = true;

  return instance;

end

getmetatable(GemaMode).__call = GemaMode.__construct;


-- Getters and setters

---
-- Returns the command list.
--
-- @treturn CommandList The command list
--
function GemaMode:getCommandList()
  return self.commandList;
end

---
-- Returns the command loader.
--
-- @treturn CommandLoader The command loader
--
function GemaMode:getCommandLoader()
  return self.commandLoader;
end

---
-- Returns the environment handler.
--
-- @treturn EnvironmentHandler The environment handler
--
function GemaMode:getEnvironmentHandler()
  return self.environmentHandler;
end

---
-- Returns the gema mode state updater.
--
-- @treturn GemaModeStateUpdater The gema mode state updater
--
function GemaMode:getGemaModeStateUpdater()
  return self.gemaModeStateUpdater;
end

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

---
-- Returns whether the gema mode is active.
--
-- @treturn bool True if the gema mode is active, false otherwise
--
function GemaMode:getIsActive()
  return self.isActive;
end

---
-- Sets whether the gema mode is active.
--
-- @tparam bool _isActive If true, the gema mode will be active, if false it will be deactivated
--
function GemaMode:setIsActive(_isActive)
  self.isActive = _isActive;
end


-- Public Methods

---
-- Loads the commands and generates the gema maprot.
--
function GemaMode:initialize()

  self:parseConfig()

  -- Load all commands
  self.commandList = self.commandLoader:loadCommands(self, "lua/scripts/wesenGemaMod/Commands");

  self.mapRot:loadGemaMapRot();
  self.environmentHandler:initialize(self.mapRot);
  self.mapTopHandler:initialize();

  self.eventHandler:loadEventHandlers(self, "lua/scripts/wesenGemaMod/EventHandler")
  self.eventHandler:initializeEventListeners()

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
