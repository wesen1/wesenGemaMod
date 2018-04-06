---
-- The lua unit test suite
--
local lfs = require("lfs");

package.path = package.path .. ";" .. lfs.currentdir() .. "/../src/wesenGemaMod/?.lua"
                            .. ";" .. lfs.currentdir() .. "/wesenGemaMod/?.lua";


-- Require luacov to get coverage information about the tests
require("luacov");

local luaunit = require("luaunit");


-- Require all files in the tests/wesenGemaMod directory
for luaFile in lfs.dir(lfs.currentdir() .. "/wesenGemaMod") do

  if (luaFile ~= "." and luaFile ~= "..") then
    require(luaFile:gsub(".lua", ""));
  end

end

-- Run the tests
os.exit( luaunit.LuaUnit:run() )
