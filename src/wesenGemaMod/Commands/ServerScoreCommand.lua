---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require "CommandManager.BaseCommand"
local CommandArgument = require "CommandManager.CommandArgument"
local ScoreContextProvider = require "GemaScoreManager.ScoreContextProvider"
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
      StaticString("serverscoreCommandAlias2"):getString(),
      StaticString("serverscoreCommandAlias3"):getString()
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

  local gemaScoreManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaScoreManager")
  local serverTopManager = gemaScoreManager:getServerTopManager()

  -- Fetch information about the personal best ServerScore
  local serverScoreList = serverTopManager:getServerTop(ScoreContextProvider.CONTEXT_MAIN):getScoreList()
  local personalBestServerScore, playerName, isSelf
  if (_arguments["playerName"] ~= nil) then
    playerName = _arguments["playerName"]
    personalBestServerScore = serverScoreList:getScoreByPlayerName(playerName)
    if ((personalBestServerScore and personalBestServerScore:getPlayer():equals(_player)) or
        (not personalBestServerScore and playerName == _player:getName())
    ) then
      isSelf = true
    else
      isSelf = false
    end
  else
    playerName = _player:getName()
    isSelf = true
    personalBestServerScore = serverScoreList:getScoreByPlayer(_player)
  end

  local contextInfos = {}
  if (personalBestServerScore) then
    local scoreContextProvider = gemaScoreManager:getScoreContextProvider()
    local scorePlayer = personalBestServerScore:getPlayer()
    local scoreContexts = serverTopManager:getScoreContexts()
    table.sort(scoreContexts)

    for _, scoreContext in ipairs(scoreContexts) do
      local contextServerScoreList = serverTopManager:getServerTop(scoreContext):getScoreList()
      table.insert(
        contextInfos,
        {
          contextName = scoreContextProvider:getPreferredAliasForScoreContext(scoreContext),
          score = contextServerScoreList:getScoreByPlayer(scorePlayer),
          numberOfScores = contextServerScoreList:getNumberOfScores()
        }
      )
    end

  end

  local gemaMapManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaMapManager")

  self.output:printTableTemplate(
    "Commands/ServerScore/ServerScore",
    {
      personalBestServerScore = personalBestServerScore,
      playerName = playerName,
      isSelf = isSelf,
      numberOfServerScores = serverScoreList:getNumberOfScores(),
      numberOfGemaMaps = gemaMapManager:getNumberOfGemaMaps(),
      contextInfos = contextInfos
    },
    _player
  )

end


return ServerScoreCommand
