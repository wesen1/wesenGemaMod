---
-- The lua unit test suite
--

--
-- Add the path to the wesenGemaMod classes to the package path list
-- in order to be able to omit this path portion in require() calls
--
package.path = package.path .. ";./../src/wesenGemaMod/?.lua";

package.path = package.path .. ";/home/travis/build/wesen1/wesenGemaMod/install/luarocks/share/lua/5.1/LuaORM/LuaORM/?.lua"

local lfs = require("lfs");

-- Require luacov to get coverage information about the tests
require("luacov");

local luaunit = require("TestFrameWork/LuaUnitCustom");
unpack = unpack or table.unpack;

-- Require the global variables that are provided by the lua server
require("globals");


function initializeORM()

  local LuaORM_API = require("LuaORM/API")

  LuaORM_API.ORM:initialize({
    connection = "LuaSQL/MySQL",
    database = {
      databaseName = "assaultcube_gema_tests",
      host = "127.0.0.1",
      portNumber = 3306,
      userName = "assaultcube",
      password = "password"
    },
    logger = { isEnabled = true, isDebugEnabled = false }
  })

end

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


initializeORM()

-- Require all lua files in the wesenGemaMod sub directory
requireTests("wesenGemaMod");

-- Run the tests
os.exit(luaunit.LuaUnit:run())
