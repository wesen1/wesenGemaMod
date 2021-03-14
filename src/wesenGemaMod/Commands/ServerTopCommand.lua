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
local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"

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

  local startRankArgument = CommandArgument(
    StaticString("serverTopCommandStartRankArgumentName"):getString(),
    true,
    "integer",
    StaticString("serverTopCommandStartRankArgumentShortName"):getString(),
    StaticString("serverTopCommandStartRankArgumentDescription"):getString()
  )

  BaseCommand.new(
    self,
    StaticString("serverTopCommandName"):getString(),
    0,
    StaticString("serverTopCommandGroupName"):getString(),
    { startRankArgument },
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
  local serverScoreList = gemaScoreManager:getServerTopManager():getServerTop(ScoreContextProvider.CONTEXT_MAIN):getScoreList()

  local numberOfScores = serverScoreList:getNumberOfScores()

  local startRank = 1
  if (numberOfScores ~= 0 and _arguments["startRank"] ~= nil) then
    -- Only check the startRank option if there are server scores
    if (_arguments["startRank"] > numberOfScores) then
      error(TemplateException(
        "Commands/ServerTop/Exceptions/StartRankHigherThanNumberOfScores",
        { maximumStartRank = numberOfScores }
      ))
    end

    startRank = _arguments["startRank"]
  end

  local numberOfDisplayedScores = 5
  if (startRank + numberOfDisplayedScores - 1 > numberOfScores) then
    numberOfDisplayedScores = numberOfScores - startRank + 1
  end

  local gemaMapManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaMapManager")

  self.output:printTableTemplate(
    "ServerScoreManager/ServerTop/ServerTop",
    { ["serverScoreList"] = serverScoreList,
      ["numberOfDisplayedScores"] = numberOfDisplayedScores,
      ["startRank"] = startRank,
      ["numberOfGemaMaps"] = gemaMapManager:getNumberOfGemaMaps()
    },
    _player
  )

end


return ServerTopCommand
