---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("CommandHandler/BaseCommand");
local CommandListPrinter = require("CommandHandler/CommandPrinter/CommandListPrinter");

---
-- Command !cmds.
-- Displays all available commands to a player
-- CmdsCommand inherits from BaseCommand
--
-- @type CmdsCommand
--
local CmdsCommand = setmetatable({}, {__index = BaseCommand});


---
-- The command list printer
--
-- @tfield CommandListPrinter commandListPrinter
--
CmdsCommand.commandListPrinter = nil;


---
-- CmdsCommand constructor.
--
-- @tparam CommandList _parentCommandList The parent command list
--
-- @treturn CmdsCommand The CmdsCommand instance
--
function CmdsCommand:__construct(_parentCommandList)

  local instance = BaseCommand(
    _parentCommandList,
    "!cmds",
    0,
    nil,
    {},
    "Displays a list of all commands that a player can use.",
    { "!commands" }
  );
  setmetatable(instance, {__index = CmdsCommand});
  
  instance.commandListPrinter = CommandListPrinter(instance.output);

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
  self.output:print(self.output:getColor("cmdsTitle") .. "Available commands:", _player);
  self.commandListPrinter:printGroupedCommands(self.parentCommandList, _player:getLevel(), " ", _player);
end


return CmdsCommand;
