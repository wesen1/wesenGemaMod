---
-- This file adds a custom assertIsInstaceOf method to luaunit
--
local luaunit = require("luaunit");

-- Add a custom assertInstanceOf method to luaunit

function luaunit.assertInstanceOf(_object, _class)

  local metaTable = getmetatable(_object);
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

function luaunit.assertError(_expectedExceptionMessage, _functionCall)

  local status, exception = pcall(_functionCall);

  if (not status) then

    local exceptionMessage = exception:getMessage();
    if (exceptionMessage == _expectedExceptionMessage) then
      return true;
    else
      error("Unexpected exception message.\n"
         .. "Expected \"" .. _expectedExceptionMessage .. "\", Got: \"" .. exceptionMessage .. "\"");
    end

  else
    error("No exception occurred while calling the function");
  end

end


return luaunit;
