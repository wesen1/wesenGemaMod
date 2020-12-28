---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require "CommandManager.BaseCommand"
local Server = require "AC-LuaServer.Core.Server"
local StaticString = require "Output.StaticString"

---
-- Command !servertop.
-- Displays the top 5 players of the server to a player
--
-- @type ServerTopCommand
--
local ServerTopCommand = BaseCommand:extend()


---
-- ServerTopCommand constructor.
--
function ServerTopCommand:new()

  BaseCommand.new(
    self,
    StaticString("serverTopCommandName"):getString(),
    0,
    StaticString("serverTopCommandGroupName"):getString(),
    {},
    StaticString("serverTopCommandDescription"):getString(),
    { StaticString("serverTopCommandAlias1"):getString() }
  )

end


-- Public Methods

---
-- Displays the 5 best players of this server to a player.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
function ServerTopCommand:execute(_player, _arguments)

  local serverScoreManager = Server.getInstance():getExtensionManager():getExtensionByName("ServerScoreManager")
  local serverScoreList = serverScoreManager:getServerTop("main"):getServerScoreList()
  local numberOfDisplayedScores = 5
  local startRank = 1

  self.output:printTableTemplate(
    "ServerScoreManager/ServerTop/ServerTop",
    { ["serverScoreList"] = serverScoreList,
      ["numberOfDisplayedScores"] = numberOfDisplayedScores,
      ["startRank"] = startRank
    }
    , _player
  )

end


return ServerTopCommand
