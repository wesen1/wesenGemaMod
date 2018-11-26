---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local lfs = require("lfs");
local CommandList = require("CommandHandler/CommandList");

---
-- Loads all commands from a specified commands directory.
--
-- @type CommandLoader
--
local CommandLoader = setmetatable({}, {});


---
-- CommandLoader constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn CommandLoader The CommandLoader instance
--
function CommandLoader:__construct()

  local instance = setmetatable({}, {__index = CommandLoader});

  return instance;

end

getmetatable(CommandLoader).__call = CommandLoader.__construct;


-- Public Methods

---
-- Loads all commands from a specified commands directory and returns a CommandList.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode for the CommandList
-- @tparam string _commandClassesDirectoryPath The path to the command classes directory
--
-- @treturn CommandList The command list that contains the loaded commands
--
function CommandLoader:loadCommands(_parentGemaMode, _commandClassesDirectoryPath)

  local commandList = CommandList(_parentGemaMode);

  for _, commandClassName in ipairs(self:getCommandClassNames(_commandClassesDirectoryPath)) do
    local commandClass = require("Commands/" .. commandClassName);
    local commandInstance = commandClass();
    commandList:addCommand(commandInstance);
  end

  return commandList;

end


-- Private Methods

---
-- Returns the list of command class names from the Commands folder sorted by name.
--
-- @tparam string _commandClassesDirectoryPath The path to the command classes directory
--
-- @treturn string[] The list of command class names
--
function CommandLoader:getCommandClassNames(_commandClassesDirectoryPath)

  local commandClassNames = {};

  -- Iterate over each file in the Commands directory
  for luaFile in lfs.dir(_commandClassesDirectoryPath) do

    -- If the file name ends with "Command.lua"
    if (luaFile:match("^.+Command.lua$")) then
      local commandClassName = luaFile:gsub(".lua", "");
      table.insert(commandClassNames, commandClassName);
    end

  end

  table.sort(commandClassNames);

  return commandClassNames;

end


return CommandLoader;
