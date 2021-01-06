---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require "CommandManager.BaseCommand"
local LatestGemaMapsCollector = require "Commands.LatestMaps.LatestGemaMapsCollector"
local StaticString = require "Output.StaticString"

---
-- Command !latestmaps.
-- Shows the x latest uploaded gema maps
--
-- @type LatestMapsCommand
--
local LatestMapsCommand = BaseCommand:extend()

---
-- The LatestGemaMapsCollector
--
-- @tfield LatestGemaMapsCollector latestGemaMapsCollector
--
LatestMapsCommand.latestGemaMapsCollector = nil


---
-- LatestMapsCommand constructor.
--
-- @tparam int _numberOfLatestGemaMaps The maximum number of latest gema maps to show
--
function LatestMapsCommand:new(_numberOfLatestGemaMaps)

  BaseCommand.new(
    self,
    StaticString("latestMapsCommandName"):getString(),
    0,
    StaticString("latestMapsCommandGroupName"):getString(),
    {},
    StaticString("latestMapsCommandDescription"):getString(),
    { StaticString("latestMapsCommandAlias1"):getString() }
  )

  self.latestGemaMapsCollector = LatestGemaMapsCollector(_numberOfLatestGemaMaps or 5)

end


-- Public Methods

---
-- Initializes this Extension.
--
function LatestMapsCommand:initialize()
  BaseCommand.initialize(self)
  self.latestGemaMapsCollector:initialize()
end

---
-- Terminates this Extension.
--
function LatestMapsCommand:terminate()
  BaseCommand.terminate(self)
  self.latestGemaMapsCollector:terminate()
end

---
-- Shows the x latest uploaded gema maps to a player.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
function LatestMapsCommand:execute(_player, _arguments)

  self.output:printTableTemplate(
    "Commands/LatestMaps/LatestMapsList",
    { maps = self.latestGemaMapsCollector:getLatestGemaMaps() },
    _player
  )

end


return LatestMapsCommand
