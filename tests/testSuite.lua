---
-- The lua unit test suite
--

--
-- Add the path to the wesenGemaMod classes to the package path list
-- in order to be able to omit this path portion in require() calls
--
package.path = package.path .. ";./../src/wesenGemaMod/?.lua";


local lfs = require("lfs");

-- Require luacov to get coverage information about the tests
require("luacov");

local luaunit = require("TestFrameWork/LuaUnitCustom");
unpack = unpack or table.unpack;

-- Require the global variables that are provided by the lua server
require("globals");


---
-- Requires all lua files in a specific test directory.
--
-- @tparam string _testDirectoryPath The path to the tests directory relative from this folder
--
local function requireTests(_testDirectoryPath)

  for luaFileName in lfs.dir(_testDirectoryPath) do

    if (luaFileName ~= "." and luaFileName ~= "..") then

      local luaFilePath = _testDirectoryPath .. "/" .. luaFileName;
      local attr = lfs.attributes(luaFilePath);

      if (attr.mode == "directory") then
        requireTests(luaFilePath);
      else

        local className = luaFileName:gsub(".lua", "");
        _G[className] = require(luaFilePath:gsub(".lua", ""));
      end

    end

  end

end


-- Require all lua files in the wesenGemaMod sub directory
requireTests("wesenGemaMod");

-- Run the tests
os.exit(luaunit.LuaUnit:run())
