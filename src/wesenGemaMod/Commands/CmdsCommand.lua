---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("CommandHandler/BaseCommand");
local StaticString = require("Output/StaticString");

---
-- Command !cmds.
-- Displays all available commands to a player
-- CmdsCommand inherits from BaseCommand
--
-- @type CmdsCommand
--
local CmdsCommand = setmetatable({}, {__index = BaseCommand});


---
-- CmdsCommand constructor.
--
-- @treturn CmdsCommand The CmdsCommand instance
--
function CmdsCommand:__construct()

  local instance = BaseCommand(
    StaticString("cmdsCommandName"):getString(),
    0,
    nil,
    {},
    StaticString("cmdsCommandDescription"):getString(),
    { StaticString("cmdsCommandAlias1"):getString() }
  );
  setmetatable(instance, {__index = CmdsCommand});

  return instance;

end

getmetatable(CmdsCommand).__call = CmdsCommand.__construct;


-- Public Methods

---
-- Displays an auto generated list of all commands.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
function CmdsCommand:execute(_player, _arguments)

  self.output:printTableTemplate(
    "TableTemplate/Commands/CmdsCommandList",
    { commandList = self.parentCommandList, maximumLevel = _player:getLevel() }
    , _player
  )

end


return CmdsCommand
