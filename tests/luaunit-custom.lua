---
-- This file adds a custom assertIsInstaceOf method to luaunit
--
local luaunit = require("luaunit");

-- Add a custom assertInstanceOf method to luaunit

function luaunit.assertInstanceOf(_object, _class)

  local metaTable = getmetatable(_object)
  if (metaTable == nil) then
    error("The object is not an instance of the specified class");
  else

    local parentClass = metaTable.__index;
    if (parentClass == _class) then
      return true;
    else
      return luaunit.assertInstanceOf(parentClass, _class);
    end

  end

end


return luaunit;
