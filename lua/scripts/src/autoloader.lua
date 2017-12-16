---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

---
-- Handles autoloading of lua files.
--
Autoloader = {};

---
-- Adds a directory to the package path if it isn't included in it yet.
--
-- In order for require() to work, the directory path of the file must be added to package.path
--
-- @param _filePath (String) File path
--
function Autoloader:registerPath(_filePath)

  if not (package.path:find(_filePath)) then
    package.path = package.path .. ";./" .. _filePath .. "/?.lua";
  end

end

---
-- Adds a file path and all its sub directories to the package path.
--
-- @param _filePath (String) File path
--
function Autoloader:register(_filePath)

  self:registerPath(_filePath);

  local lfs = require("lfs");

  -- iterate over each file in _filePath
  for luaFile in lfs.dir(_filePath) do

    if (luaFile ~= "." and luaFile ~= "..") then

      local attributes = lfs.attributes(_filePath .. "/" .. luaFile);

      if (attributes.mode == "directory") then
        self:register(_filePath .. "/" .. luaFile);
      end

    end

  end

end

---
-- Requires all lua files in _filePath and ignores subdirectories.
--
-- @param _filePath (String) File path
--
-- @return (table) List of return values of the lua files
--
function Autoloader:requireFiles(_filePath)

  local lfs = require("lfs");
  local files = {};

  -- iterate over each file in _filePath
  for luaFile in lfs.dir(_filePath) do

    if (luaFile ~= "." and luaFile ~= "..") then

      local attributes = lfs.attributes(_filePath .. "/" .. luaFile);

      if (attributes.mode == "file") then
        table.insert(files, require(luaFile:gsub(".lua", "")));
      end

    end

  end
  
  return files;

end

---
-- Loads all commands and returns a list containing the commands.
--
-- @param _filePath (String) File path to commands directory
-- @param _commandLister (CommandLister) Command lister that will be used to store the commands
--
-- @return (CommandLister) List of commands
--
function Autoloader:loadCommands(_filePath, _commandLister)

  local files = self:requireFiles(_filePath);
  
  for index, command in ipairs(files) do

    _commandLister:addCommand(command);    
    print("Loaded command !" .. command:getName());
    
  end
  
  return _commandLister;
  
end


return Autoloader;

