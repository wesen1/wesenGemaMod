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
    StaticString("mapsoreCommandName"):getString(),
    0,
    StaticString("mapscoreCommandGroupName"):getString(),
    { playerNameArgument },
    StaticString("mapscoreCommandDescription"):getString(),
    {
      StaticString("mapscoreCommandAlias1"):getString(),
      StaticString("mapscoreCommandAlias2"):getString(),
      StaticString("mapscoreCommandAlias3"):getString()
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

  local gemaGameMode = Server.getInstance():getExtensionManager():getExtensionByName("GemaGameMode")
  local mapRecordList = gemaGameMode:getMapTopHandler():getMapTop("main"):getMapRecordList()

  local mapRecord, playerName, isSelf
  if (_arguments["playerName"] ~= nil) then
    playerName = _arguments["playerName"]
    mapRecord = mapRecordList:getBestRecordForPlayerName(playerName)
    if ((mapRecord and mapRecord:getPlayer():equals(_player)) or
        (not mapRecord and playerName == _player:getName())
    ) then
      isSelf = true
    else
      isSelf = false
    end
  else
    playerName = _player:getName()
    isSelf = true
    mapRecord = mapRecordList:getRecordByPlayer(_player)
  end

  self.output:printTextTemplate(
    "Commands/MapScore/MapScore",
    { ["mapRecord"] = mapRecord,
      ["playerName"] = playerName,
      ["isSelf"] = isSelf,
      ["numberOfMapScores"] = mapRecordList:getNumberOfRecords()
    }
    , _player
  )

end


return MapScoreCommand
