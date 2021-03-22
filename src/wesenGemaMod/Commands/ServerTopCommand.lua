---
-- @author wesen
-- @copyright 2020-2021 wesen <wesen-ac@web.de>
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
-- Command !servertop.
-- Displays the top 5 players of the server to a player
--
-- @type ServerTopCommand
--
local ServerTopCommand = BaseCommand:extend()

---
-- The default number of scores to show when the numberOfScores option is not set
-- Defaults to 5
--
-- @tfield int defaultNumberOfDisplayScores
--
ServerTopCommand.defaultNumberOfDisplayScores = nil


---
-- ServerTopCommand constructor.
--
-- @tparam int _defaultNumberOfDisplayScores The default number of display scores to show (optional)
--
function ServerTopCommand:new(_defaultNumberOfDisplayScores)

  self.defaultNumberOfDisplayScores = _defaultNumberOfDisplayScores or 5

  local contextArgument = CommandArgument(
    StaticString("servertopCommandContextArgumentName"):getString(),
    true,
    "string",
    StaticString("servertopCommandContextArgumentShortName"):getString(),
    StaticString("servertopCommandContextArgumentDescription"):getString()
  )

  local startRankArgument = CommandArgument(
    StaticString("serverTopCommandStartRankArgumentName"):getString(),
    true,
    "integer",
    StaticString("serverTopCommandStartRankArgumentShortName"):getString(),
    StaticString("serverTopCommandStartRankArgumentDescription"):getString()
  )

  local numberOfDisplayScoresArgument = CommandArgument(
    StaticString("serverTopCommandNumberOfScoresArgumentName"):getString(),
    true,
    "integer",
    StaticString("serverTopCommandNumberOfScoresArgumentShortName"):getString(),
    StaticString("serverTopCommandNumberOfScoresArgumentDescription"):getString():format(self.defaultNumberOfDisplayScores)
  )

  BaseCommand.new(
    self,
    StaticString("serverTopCommandName"):getString(),
    0,
    StaticString("serverTopCommandGroupName"):getString(),
    { contextArgument, startRankArgument, numberOfDisplayScoresArgument },
    StaticString("serverTopCommandDescription"):getString(),
    { StaticString("serverTopCommandAlias1"):getString() }
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
function ServerTopCommand:validateInputArguments(_arguments)

  if (_arguments["startRank"] ~= nil and _arguments["startRank"] < 1) then
    error(TemplateException(
      "Commands/ServerTop/Exceptions/StartRankLowerThanOne", {}
    ))
  end

end

---
-- Displays the 5 best players of this server to a player.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
function ServerTopCommand:execute(_player, _arguments)

  local gemaScoreManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaScoreManager")
  local scoreContextProvider = gemaScoreManager:getScoreContextProvider()

  local scoreContextResolver = ScoreContextResolver(gemaScoreManager)
  local scoreContext, serverTop = scoreContextResolver:getServerTopForScoreContext(_arguments["context"])
  local serverScoreList = serverTop:getScoreList()

  local numberOfScores = serverScoreList:getNumberOfScores()

  local startRank = 1
  if (numberOfScores ~= 0 and _arguments["startRank"] ~= nil) then
    -- Only check the startRank option if there are server scores
    if (_arguments["startRank"] > numberOfScores) then
      error(TemplateException(
        "Commands/ServerTop/Exceptions/StartRankHigherThanNumberOfScores",
        {
          maximumStartRank = numberOfScores,
          scoreContextProvider = scoreContextProvider,
          scoreContext = scoreContext
        }
      ))
    end

    startRank = _arguments["startRank"]
  end

  local numberOfDisplayedScores = _arguments["numberOfScores"] or self.defaultNumberOfDisplayScores
  if (startRank + numberOfDisplayedScores - 1 > numberOfScores) then
    numberOfDisplayedScores = numberOfScores - startRank + 1
  end

  local gemaMapManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaMapManager")

  self.output:printTableTemplate(
    "Commands/ServerTop/ServerTop",
    {
      ["serverScoreList"] = serverScoreList,
      ["numberOfDisplayedScores"] = numberOfDisplayedScores,
      ["startRank"] = startRank,
      ["numberOfGemaMaps"] = gemaMapManager:getNumberOfGemaMaps(),
      ["scoreContextProvider"] = scoreContextProvider,
      ["scoreContext"] = scoreContext
    },
    _player
  )

end


return ServerTopCommand
