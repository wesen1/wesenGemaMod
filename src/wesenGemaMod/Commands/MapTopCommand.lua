---
-- @author wesen
-- @copyright 2017-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require "CommandManager.BaseCommand"
local CommandArgument = require "CommandManager.CommandArgument"
local ScoreContextResolver = require "GemaScoreManager.CommandUtil.ScoreContextResolver"
local Server = require "AC-LuaServer.Core.Server"
local StaticString = require "Output.StaticString"
local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"

---
-- Command !maptop.
-- Displays the best records of a map to a player
--
-- @type MapTopCommand
--
local MapTopCommand = BaseCommand:extend()

---
-- The default number of scores to show when the numberOfScores option is not set
-- Defaults to 5
--
-- @tfield int defaultNumberOfDisplayScores
--
MapTopCommand.defaultNumberOfDisplayScores = nil


---
-- MapTopCommand constructor.
--
-- @tparam int _defaultNumberOfDisplayScores The default number of display scores to show (optional)
--
function MapTopCommand:new(_defaultNumberOfDisplayScores)

  self.defaultNumberOfDisplayScores = _defaultNumberOfDisplayScores or 5

  local contextArgument = CommandArgument(
    StaticString("maptopCommandContextArgumentName"):getString(),
    true,
    "string",
    StaticString("maptopCommandContextArgumentShortName"):getString(),
    StaticString("maptopCommandContextArgumentDescription"):getString()
  )

  local startRankArgument = CommandArgument(
    StaticString("maptopCommandStartRankArgumentName"):getString(),
    true,
    "integer",
    StaticString("maptopCommandStartRankArgumentShortName"):getString(),
    StaticString("maptopCommandStartRankArgumentDescription"):getString()
  )

  local numberOfDisplayScoresArgument = CommandArgument(
    StaticString("maptopCommandNumberOfScoresArgumentName"):getString(),
    true,
    "integer",
    StaticString("maptopCommandNumberOfScoresArgumentShortName"):getString(),
    StaticString("maptopCommandNumberOfScoresArgumentDescription"):getString():format(self.defaultNumberOfDisplayScores)
  )

  self.super.new(
    self,
    StaticString("mapTopCommandName"):getString(),
    0,
    StaticString("mapTopCommandGroupName"):getString(),
    { contextArgument, startRankArgument, numberOfDisplayScoresArgument },
    StaticString("mapTopCommandDescription"):getString(),
    { StaticString("mapTopCommandAlias1"):getString() }
  )

end


-- Public Methods

---
-- Validates the input arguments.
--
-- @tparam mixed[] _arguments The list of arguments
--
-- @raise Error in case of an invalid input argument
--
function MapTopCommand:validateInputArguments(_arguments)

  if (_arguments["startRank"] ~= nil and _arguments["startRank"] < 1) then
    error(TemplateException(
      "Commands/MapTop/Exceptions/StartRankLowerThanOne", {}
    ))
  end

end

---
-- Displays the 5 best players of a map to a player.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
function MapTopCommand:execute(_player, _arguments)

  local gemaScoreManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaScoreManager")
  local scoreContextProvider = gemaScoreManager:getScoreContextProvider()

  local scoreContextResolver = ScoreContextResolver(gemaScoreManager)
  local scoreContext, mapTop = scoreContextResolver:getMapTopForScoreContext(_arguments["context"])
  local mapScoreList = mapTop:getScoreList()

  local numberOfScores = mapScoreList:getNumberOfScores()

  local startRank = 1
  if (numberOfScores ~= 0 and _arguments["startRank"] ~= nil) then
    -- Only check the startRank option if there are records
    if (_arguments["startRank"] > numberOfScores) then
      error(TemplateException(
        "Commands/MapTop/Exceptions/StartRankHigherThanNumberOfRecords",
        {
          maximumStartRank = numberOfScores,
          scoreContextProvider = scoreContextProvider,
          scoreContext = scoreContext
        }
      ))
    end

    startRank = _arguments["startRank"]

  end

  local numberOfDisplayScores = _arguments["numberOfScores"] or self.defaultNumberOfDisplayScores
  if (startRank + numberOfDisplayScores - 1 > numberOfScores) then
    numberOfDisplayScores = numberOfScores - startRank + 1
  end

  self.output:printTableTemplate(
    "Commands/MapTop/MapTop",
    { ["mapScoreList"] = mapScoreList,
      ["numberOfDisplayScores"] = numberOfDisplayScores,
      ["startRank"] = startRank,
      ["scoreContextProvider"] = scoreContextProvider,
      ["scoreContext"] = scoreContext
    },
    _player
  )

end


return MapTopCommand
