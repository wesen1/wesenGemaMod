---
-- The lua unit test suite
--
package.path = package.path .. ";./../../scripts/src/wesenGemaMod/?.lua";


-- Require luacov to get coverage information about the tests
require("luacov");

local luaunit = require("luaunit");
local lfs = require("lfs");


-- Require all files in the tests/wesenGemaMod directory
for luaFile in lfs.dir("./wesenGemaMod") do

  if (luaFile ~= "." and luaFile ~= "..") then
    
    local includePath = "./wesenGemaMod/" .. luaFile:gsub(".lua", "");
    require(includePath);
  end

end

-- Run the tests
os.exit( M.LuaUnit:run() )
