---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Default configuration for wesenGemaMod.
--
return {
  waitMillisecondsBeforeDatabaseConnection = 5000,

  LuaORM = {
    connection = "LuaSQL/MySQL",
    database = {
      databaseName = "assaultcube_gema",
      host = "database",
      portNumber = 3306,
      userName = "assaultcube",
      password = "password"
    },
    logger = { isEnabled = true, isDebugEnabled = false }
  },

  ClientOutputFactory = {
    fontConfigFileName = "FontDefault",
    defaultConfiguration = {
      maximumLineWidth = 3900
    }
  },

  colorConfigurationFileName = "colors",

  extensions = {

    -- Core extensions
    "AC-LuaServer.Extensions.GameModeManager.GameModeManager",
    "GemaMode",
    "Extensions.GemaMapManager",
    "Extensions.MapStatisticsPrinter",
    "ScoreAttemptManager.ScoreAttemptManager",
    "Extensions.GemaMapRotationManager.GemaMapRotationManager",

    "CommandManager.CommandManager",
    "Commands.CmdsCommand",
    "Commands.HelpCommand",
    ["Commands.ExtendTimeCommand"] = { 20 },
    "Commands.MapTopCommand",
    "Commands.RulesCommand",
    "Commands.ServerTopCommand",

    -- Optional extensions
    "ServerScoreManager.ServerScoreManager",
    "Extensions.AutoFlagReset",
    "Extensions.AdditionalServerInfos",
    ["Extensions.ConnectionAmountLimiter"] = { 2 },
    "Extensions.UnplayableGemaMapsRemover",
    "Extensions.GlobalVoicecom"
  }
}
