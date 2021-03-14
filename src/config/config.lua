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
  databaseKeepAliveQueryInterval = 30 * 60 * 1000,
  databaseKeepAliveQuery = "SELECT COUNT(`maps`.`id`) FROM `maps`;",

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
    [ "GemaScoreManager.GemaScoreManager" ] = {
      {
        mergeScoresByPlayerName = true,
        contexts = {
          "main", "knife", "pistol", "assault-rifle", "submachine-gun", "sniper-rifle", "shotgun", "carbine"
        }
      },
      {
        mergeScoresByPlayerName = true,
        contexts = {
          "main", "knife", "pistol", "assault-rifle", "submachine-gun", "sniper-rifle", "shotgun", "carbine"
        }
      }
    },
    "Extensions.GemaMapManager",
    "Extensions.MapStatisticsPrinter",
    "Extensions.GemaMapRotationManager",

    "CommandManager.CommandManager",
    "Commands.CmdsCommand",
    "Commands.HelpCommand",
    ["Commands.ExtendTimeCommand"] = { 20 },
    "Commands.MapTopCommand",
    "Commands.MapScoreCommand",
    "Commands.RulesCommand",
    "Commands.ServerTopCommand",
    "Commands.ServerScoreCommand",
    "Commands.ResetCommand",
    "Commands.LatestMapsCommand",

    -- Optional extensions
    "Extensions.AutoFlagReset",
    "Extensions.AdditionalServerInfos",
    ["Extensions.ConnectionAmountLimiter"] = { 2 },
    "Extensions.UnplayableGemaMapsRemover",
    "Extensions.GlobalVoicecom",
    "Extensions.ItemReset"
  }
}
