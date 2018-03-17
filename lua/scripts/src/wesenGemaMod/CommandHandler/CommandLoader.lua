---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local lfs = require("lfs");

---
-- Loads all commands from the Commands directory.
--
-- @type CommandLoader
--
local CommandLoader = {};


---
-- The parent command handler
--
-- @tfield CommandHandler parentCommandHandler
--
CommandLoader.parentCommandHandler = "";


---
-- CommandLoader constructor.
--
-- @tparam CommandHandler _parentCommandHandler The parent command handler
--
-- @treturn CommandLoader The CommandLoader instance
--
function CommandLoader:__construct(_parentCommandHandler)

  local instance = {};
  setmetatable(instance, {__index = CommandLoader});

  instance.parentCommandHandler = _parentCommandHandler;

  return instance;

end


-- Getters and setters

---
-- Returns the parent command handler.
--
-- @treturn CommandHandler The parent command handler
--
function CommandLoader:getParentCommandHandler()
  return self.parentCommandHandler;
end

---
-- Sets the parent command handler.
--
-- @tparam CommandHandler _parentCommandHandler The parent command handler
--
function CommandLoader:setParentCommandHandler(_parentCommandHandler)
  self.parentCommandHandler = _parentCommandHandler;
end


-- Class Methods

---
-- Loads all commands from the Commands directory and adds them to _commandLister.
--
-- @tparam CommandLister _commandLister The command lister
--
function CommandLoader:loadCommands(_commandLister)

  for index, commandClassName in ipairs(self:getCommandClassNames()) do
    local command = require("Commands/" .. commandClassName);
    _commandLister:addCommand(command);
  end

end

---
-- Returns the list of command class names from the Commands folder sorted by name.
--
-- @treturn table The list of command class names
--
function CommandLoader:getCommandClassNames()

  local commandClassNames = {};

  -- iterate over each file in the Commands directory
  for luaFile in lfs.dir("lua/scripts/src/wesenGemaMod/Commands") do

    if (luaFile ~= "." and luaFile ~= ".." and luaFile ~= "BaseCommand.lua") then
      local commandClassName = luaFile:gsub(".lua", "");
      table.insert(commandClassNames, commandClassName);
    end

  end

  table.sort(commandClassNames);

  return commandClassNames;

end


return CommandLoader;
