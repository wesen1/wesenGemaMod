---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require "CommandManager.BaseCommand"
local CommandArgument = require "CommandManager.CommandArgument"
local Server = require "AC-LuaServer.Core.Server"
local StaticString = require "Output.StaticString"

---
-- Command !serverscore.
-- Displays the server score / grank of a player.
--
-- @type ServerScoreCommand
--
local ServerScoreCommand = BaseCommand:extend()


---
-- ServerScoreCommand constructor.
--
function ServerScoreCommand:new()

  local playerNameArgument = CommandArgument(
    StaticString("serverscoreCommandPlayerNameArgumentName"):getString(),
    true,
    "string",
    StaticString("serverscoreCommandPlayerNameArgumentShortName"):getString(),
    StaticString("serverscoreCommandPlayerNameArgumentDescription"):getString()
  )

  self.super.new(
    self,
    StaticString("serverscoreCommandName"):getString(),
    0,
    StaticString("serverscoreCommandGroupName"):getString(),
    { playerNameArgument },
    StaticString("serverscoreCommandDescription"):getString(),
    {
      StaticString("serverscoreCommandAlias1"):getString(),
      StaticString("serverscoreCommandAlias2"):getString()
    }
  )

end


-- Public Methods

---
-- Displays the server score / grank of a player.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
function ServerScoreCommand:execute(_player, _arguments)

  local serverScoreManager = Server.getInstance():getExtensionManager():getExtensionByName("ServerScoreManager")
  local serverScoreList = serverScoreManager:getServerTop("main"):getServerScoreList()

  local serverScore, playerName, isSelf
  if (_arguments["playerName"] ~= nil) then
    playerName = _arguments["playerName"]
    serverScore = serverScoreList:getBestScoreForPlayerName(playerName)
    if ((serverScore and serverScore:getPlayer():equals(_player)) or
        (not serverScore and playerName == _player:getName())
    ) then
      isSelf = true
    else
      isSelf = false
    end
  else
    playerName = _player:getName()
    isSelf = true
    serverScore = serverScoreList:getScoreByPlayer(_player)
  end

  self.output:printTextTemplate(
    "Commands/ServerScore/ServerScore",
    { ["serverScore"] = serverScore,
      ["playerName"] = playerName,
      ["isSelf"] = isSelf,
      ["numberOfServerScores"] = serverScoreList:getNumberOfScores()
    }
    , _player
  )

end


return ServerScoreCommand
