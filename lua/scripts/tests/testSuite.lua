---
-- The lua unit test suite
--
local lfs = require("lfs");

package.path = package.path .. ";" .. lfs.currentdir() .. "/../src/wesenGemaMod/?.lua"
                            .. ";" .. lfs.currentdir() .. "/wesenGemaMod/?.lua";


-- Require luacov to get coverage information about the tests
require("luacov");

local luaunit = require("luaunit");


function requireTests(_testDirectoryPath)
  
  for luaFileName in lfs.dir(_testDirectoryPath) do

    if (luaFileName ~= "." and luaFileName ~= "..") then

      local luaFilePath = _testDirectoryPath .. "/" .. luaFileName;
      local attr = lfs.attributes(luaFilePath);

      if (attr.mode == "directory") then
        requireTests(luaFilePath);
      else
        
        if not (package.path:find(_testDirectoryPath)) then
          package.path = package.path .. ";" .. _testDirectoryPath .. "/?.lua";
        end
        
        require(luaFileName:gsub(".lua", ""));
      end
    
    end

  end

end


-- Require all files in the tests/wesenGemaMod directory
requireTests(lfs.currentdir() .. "/wesenGemaMod");

-- Run the tests
os.exit( luaunit.LuaUnit:run() )
