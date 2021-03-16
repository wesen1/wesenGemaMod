---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require "CommandManager.BaseCommand"
local ScoreContextProvider = require "GemaScoreManager.ScoreContextProvider"
local Server = require "AC-LuaServer.Core.Server"
local StaticString = require "Output.StaticString"
local tablex = require "pl.tablex"

---
-- Command !scorecontexts.
-- Displays the available score contexts.
--
-- @type ScoreContextsCommand
--
local ScoreContextsCommand = BaseCommand:extend()


---
-- ScoreContextsCommand constructor.
--
function ScoreContextsCommand:new()

  self.super.new(
    self,
    StaticString("scoreContextsCommandName"):getString(),
    0,
    StaticString("scoreContextsCommandGroupName"):getString(),
    {},
    StaticString("scoreContextsCommandDescription"):getString()
  )

end


-- Public Methods

---
-- Displays the available score contexts to a player.
--
-- @tparam Player _player The player who executed the command
--
function ScoreContextsCommand:execute(_player)

  local gemaScoreManager = Server.getInstance():getExtensionManager():getExtensionByName("GemaScoreManager")
  local scoreContextProvider = gemaScoreManager:getScoreContextProvider()

  local availableScoreTypeScoreContexts = self:fetchAvailableScoreTypeScoreContexts(gemaScoreManager)

  local sortedScoreContexts = tablex.keys(availableScoreTypeScoreContexts)
  table.sort(sortedScoreContexts)

  local scoreContextInfos = {}
  for _, scoreContext in ipairs(sortedScoreContexts) do
    table.insert(
      scoreContextInfos,
      {
        ["id"] = scoreContext,
        ["name"] = scoreContextProvider:getPreferredAliasForScoreContext(scoreContext),
        ["usedForScoreTypes"] = availableScoreTypeScoreContexts[scoreContext]
      }
    )
  end

  self.output:printTableTemplate(
    "Commands/ScoreContexts/ScoreContexts",
    {
      ["scoreContextProvider"] = scoreContextProvider,
      ["scoreContextInfos"] = scoreContextInfos
    },
    _player
  )

end


-- Private Methods

---
-- Fetches all available score types ("MapTop", "ServerTop") per score context.
-- Score contexts without available score types will not be contained in the result.
--
-- The resulting list is in the format { [<score context>] = { <scoreType>, ... }, ... }.
--
-- @tparam GemaScoreManager _gemaScoreManager The GemaScoreManager to fetch the available score types from
--
-- @treturn int[][] The list of available score types per score context
--
function ScoreContextsCommand:fetchAvailableScoreTypeScoreContexts(_gemaScoreManager)

  local availableScoreContexts = {
    { scoreType = "MapTop", contexts = _gemaScoreManager:getMapTopManager():getScoreContexts() },
    { scoreType = "ServerTop", contexts = _gemaScoreManager:getServerTopManager():getScoreContexts() }
  }

  local scoreContexts = {}
  for _, scoreTypeScoreContexts in ipairs(availableScoreContexts) do
    for _, scoreContext in ipairs(scoreTypeScoreContexts["contexts"]) do
      if (scoreContexts[scoreContext] == nil) then
        scoreContexts[scoreContext] = {}
      end
      table.insert(scoreContexts[scoreContext], scoreTypeScoreContexts["scoreType"])
    end
  end

  return scoreContexts

end


return ScoreContextsCommand
