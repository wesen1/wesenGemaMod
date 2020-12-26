---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require "CommandManager.BaseCommand"
local StaticString = require "Output.StaticString"
local TmpUtil = require "TmpUtil.TmpUtil"

---
-- Command !maptop.
-- Displays the best records of a map to a player
--
-- @type MapTopCommand
--
local MapTopCommand = BaseCommand:extend()


---
-- MapTopCommand constructor.
--
function MapTopCommand:new()

  self.super.new(
    self,
    StaticString("mapTopCommandName"):getString(),
    0,
    StaticString("mapTopCommandGroupName"):getString(),
    {},
    StaticString("mapTopCommandDescription"):getString(),
    { StaticString("mapTopCommandAlias1"):getString() }
  )

end


-- Public Methods

---
-- Displays the 5 best players of a map to a player.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
function MapTopCommand:execute(_player, _arguments)

  local mapTopHandler = TmpUtil.getServerExtensionByName("GemaGameMode"):getMapTopHandler()

  local mapRecordList = mapTopHandler:getMapTop("main"):getMapRecordList()
  local numberOfDisplayRecords = 5
  local startRank = 1

  self.output:printTableTemplate(
    "TableTemplate/MapTop/MapTop",
    { ["mapRecordList"] = mapRecordList,
      ["numberOfDisplayRecords"] = numberOfDisplayRecords,
      ["startRank"] = startRank
    }
    , _player
  )

end


return MapTopCommand
