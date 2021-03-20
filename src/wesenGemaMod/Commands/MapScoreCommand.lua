---
-- @author wesen
-- @copyright 2020-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require "CommandManager.BaseCommand"
local CommandArgument = require "CommandManager.CommandArgument"
local ScoreContextProvider = require "GemaScoreManager.ScoreContextProvider"
local Server = require "AC-LuaServer.Core.Server"
local StaticString = require "Output.StaticString"

---
-- Command !mapscore.
-- Displays the personal best time of a player.
--
-- @type MapScoreCommand
--
local MapScoreCommand = BaseCommand:extend()


---
-- MapScoreCommand constructor.
--
function MapScoreCommand:new()

  local playerNameArgument = CommandArgument(
    StaticString("mapscoreCommandPlayerNameArgumentName"):getString(),
    true,
    "string",
    StaticString("mapscoreCommandPlayerNameArgumentShortName"):getString(),
    StaticString("mapscoreCommandPlayerNameArgumentDescription"):getString()
  )

  self.super.new(
    self,
    StaticString("mapscoreCommandName"):getString(),
    0,
    StaticString("mapscoreCommandGroupName"):getString(),
    { playerNameArgument },
    StaticString("mapscoreCommandDescription"):getString(),
    {
      StaticString("mapscoreCommandAlias1"):getString(),
      StaticString("mapscoreCommandAlias2"):getString(),
      StaticString("mapscoreCommandAlias3"):getString(),
      StaticString("mapscoreCommandAlias4"):getString()
    }
  )

end


-- Public Methods

---
-- Displays the personal best time of a player.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
function MapScoreCommand:execute(_player, _arguments)

  local gemaScoreManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaScoreManager")
  local mapTopManager = gemaScoreManager:getMapTopManager()

  -- Fetch information about the best MapScore
  local mapScoreList = mapTopManager:getMapTop(ScoreContextProvider.CONTEXT_MAIN):getScoreList()

  local personalBestMapScore, playerName, isSelf
  if (_arguments["playerName"] ~= nil) then
    playerName = _arguments["playerName"]
    personalBestMapScore = mapScoreList:getScoreByPlayerName(playerName)
    if ((personalBestMapScore and personalBestMapScore:getPlayer():equals(_player)) or
        (not personalBestMapScore and playerName == _player:getName())
    ) then
      isSelf = true
    else
      isSelf = false
    end
  else
    playerName = _player:getName()
    isSelf = true
    personalBestMapScore = mapScoreList:getScoreByPlayer(_player)
  end

  local contextInfos = {}
  if (personalBestMapScore) then
    local scoreContextProvider = gemaScoreManager:getScoreContextProvider()
    local scorePlayer = personalBestMapScore:getPlayer()
    local scoreContexts = mapTopManager:getScoreContexts()
    table.sort(scoreContexts)

    for _, scoreContext in ipairs(scoreContexts) do
      local contextMapScoreList = mapTopManager:getMapTop(scoreContext):getScoreList()
      table.insert(
        contextInfos,
        {
          contextName = scoreContextProvider:getPreferredAliasForScoreContext(scoreContext),
          score = contextMapScoreList:getScoreByPlayer(scorePlayer),
          numberOfScores = contextMapScoreList:getNumberOfScores()
        }
      )
    end

  end

  self.output:printTableTemplate(
    "Commands/MapScore/MapScore",
    {
      personalBestMapScore = personalBestMapScore,
      playerName = playerName,
      isSelf = isSelf,
      numberOfMapScores = mapScoreList:getNumberOfScores(),
      contextInfos = contextInfos
    }
    , _player
  )

end


return MapScoreCommand
