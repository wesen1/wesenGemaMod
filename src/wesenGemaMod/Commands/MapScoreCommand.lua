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
  local mapScoreList = gemaScoreManager:getMapTopManager():getMapTop("main"):getScoreList()

  local mapScore, playerName, isSelf
  if (_arguments["playerName"] ~= nil) then
    playerName = _arguments["playerName"]
    mapScore = mapScoreList:getScoreByPlayerName(playerName)
    if ((mapScore and mapScore:getPlayer():equals(_player)) or
        (not mapScore and playerName == _player:getName())
    ) then
      isSelf = true
    else
      isSelf = false
    end
  else
    playerName = _player:getName()
    isSelf = true
    mapScore = mapScoreList:getScoreByPlayer(_player)
  end

  self.output:printTextTemplate(
    "Commands/MapScore/MapScore",
    { ["mapScore"] = mapScore,
      ["playerName"] = playerName,
      ["isSelf"] = isSelf,
      ["numberOfMapScores"] = mapScoreList:getNumberOfScores()
    }
    , _player
  )

end


return MapScoreCommand
