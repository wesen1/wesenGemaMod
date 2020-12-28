---
-- @author wesen
-- @copyright 2017-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

PLUGIN_NAME = "wesen's gema mod"
PLUGIN_AUTHOR = "wesen"
PLUGIN_VERSION = "0.1"

--
-- Add the path to the wesenGemaMod classes to the package path list
-- in order to be able to omit this path portion in require() calls
--
package.path = package.path .. ";lua/scripts/wesenGemaMod/?.lua"


--
-- Require the penlight compatibility module that adds some global functions that are missing in Lua5.1
-- such as package.searchpath, table.unpack and table.pack
--
require "pl.compat"


-- Configure LuaORM
local LuaORM_API = require "LuaORM.API"

-- Wait for 5 seconds so that the database container has enough time to start
local sleep = require "sleep"
sleep(5000)

local config = cfg.totable("luaorm")
LuaORM_API.ORM:initialize({
  connection = "LuaSQL/MySQL",
  database = {
    databaseName = config.databaseName,
    host = "database",
    portNumber = 3306,
    userName = config.databaseUser,
    password = config.databasePassword
  },
  logger = { isEnabled = true, isDebugEnabled = false }
})

-- Configure AC-ClientOutput
local ClientOutputFactory = require "AC-ClientOutput.ClientOutputFactory"
local config = cfg.totable("gemamod")
ClientOutputFactory.getInstance():configure({
    fontConfigFileName = "FontDefault",
    defaultConfiguration = config
})

-- Configure AC-LuaServer
local Server = require "AC-LuaServer.Core.Server"
local server = Server.getInstance()

local Player = require "Player.Player"
server:getPlayerList():setPlayerImplementationClass(Player)

local ColorLoader = require "Config.ColorLoader"
local TimeFormatter = require "Output.TimeFormatter"
local colorConfigurationFileName = "colors"
server:configure({
  Output = {
    TemplateRenderer = {
      StringRenderer = {
        defaultTemplateValues = {
          colors = ColorLoader(colorConfigurationFileName):getColors(),
          timeFormatter = TimeFormatter()
        },
        templateBaseDirectoryPaths = {
          "lua/config/templates/"
        }
      }
    }
  }
})

-- Add the extensions to the server
local AdditionalServerInfos = require "Extensions.AdditionalServerInfos"
local AutoFlagReset = require "Extensions.AutoFlagReset"
local CmdsCommand = require "Commands.CmdsCommand"
local CommandManager = require "CommandManager.CommandManager"
local ConnectionAmountLimiter = require "Extensions.ConnectionAmountLimiter"
local ExtendTimeCommand = require "Commands.ExtendTimeCommand"
local GemaGameMode = require "GemaMode"
local GemaMapManager = require "Extensions.GemaMapManager"
local GemaMapRotationManager = require "Extensions.GemaMapRotationManager.GemaMapRotationManager"
local GameModeManager = require "AC-LuaServer.Extensions.GameModeManager.GameModeManager"
local HelpCommand = require "Commands.HelpCommand"
local MapStatisticsPrinter = require "Extensions.MapStatisticsPrinter"
local MapTopCommand = require "Commands.MapTopCommand"
local RulesCommand = require "Commands.RulesCommand"
local ScoreAttemptManager = require "ScoreAttemptManager.ScoreAttemptManager"
local ServerScoreManager = require "ServerScoreManager.ServerScoreManager"
local ServerTopCommand = require "Commands.ServerTopCommand"
local UnplayableGemaMapsRemover = require "Extensions.UnplayableGemaMapsRemover"

local extensionManager = server:getExtensionManager()

-- Core extensions
extensionManager:addExtension(GameModeManager())
extensionManager:addExtension(GemaGameMode())
extensionManager:addExtension(GemaMapManager())
extensionManager:addExtension(MapStatisticsPrinter())
extensionManager:addExtension(ScoreAttemptManager())
extensionManager:addExtension(GemaMapRotationManager())

extensionManager:addExtension(CommandManager())
extensionManager:addExtension(CmdsCommand())
extensionManager:addExtension(HelpCommand())
extensionManager:addExtension(ExtendTimeCommand())
extensionManager:addExtension(MapTopCommand())
extensionManager:addExtension(RulesCommand())
extensionManager:addExtension(ServerTopCommand())

-- Optional extensions
extensionManager:addExtension(ServerScoreManager())
extensionManager:addExtension(AutoFlagReset())
extensionManager:addExtension(AdditionalServerInfos())
extensionManager:addExtension(ConnectionAmountLimiter(2))
extensionManager:addExtension(UnplayableGemaMapsRemover())
