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

local config = require "lua.config.config"

-- Wait for a specific time so that the database container has enough time to start
local sleep = require "sleep"
sleep(config.waitMillisecondsBeforeDatabaseConnection or 5000)

-- Configure LuaORM
local LuaORM_API = require "LuaORM.API"
LuaORM_API.ORM:initialize(config.LuaORM or {})

local Timer = require "AC-LuaServer.Core.Util.Timer"
local keepDatabaseConnectionAliveTimer = Timer(
  Timer.TYPE_PERIODIC,
  config.databaseKeepAliveQueryInterval or 30 * 60 * 1000,
  function()
    LuaORM_API.ORM:getDatabaseConnection():execute("DO 0;")
  end
)


-- Configure AC-ClientOutput
local ClientOutputFactory = require "AC-ClientOutput.ClientOutputFactory"
ClientOutputFactory.getInstance():configure(config.ClientOutputFactory or {})

-- Configure AC-LuaServer
local Server = require "AC-LuaServer.Core.Server"
local server = Server.getInstance()

local Player = require "Player.Player"
server:getPlayerList():setPlayerImplementationClass(Player)

local ColorLoader = require "Config.ColorLoader"
local TimeFormatter = require "Output.TimeFormatter"
server:configure({
  Output = {
    TemplateRenderer = {
      StringRenderer = {
        defaultTemplateValues = {
          colors = ColorLoader(config.colorConfigurationFileName or "colors"):getColors(),
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
local extensionManager = server:getExtensionManager()

local extensionPath, constructorParameters, extensionClass
for key, value in pairs(config.extensions or {}) do

  if (type(key) == "string" and type(value) == "table") then
    extensionPath = key
    constructorParameters = value
  else
    extensionPath = value
    constructorParameters = {}
  end

  extensionClass = require(extensionPath)
  extensionManager:addExtension(extensionClass(table.unpack(constructorParameters)))

end
