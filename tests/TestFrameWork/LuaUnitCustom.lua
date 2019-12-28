---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local luaunit = require("luaunit");

---
-- Adds additional methods to luaunit that the unit tests can use.
--
-- @type LuaUnitCustom
--
local LuaUnitCustom = setmetatable({}, { __index = luaunit });


---
-- Asserts that an object is a instance of a specific class.
--
-- @tparam table _object The object
-- @tparam table _class The expected parent class
--
-- @raise Error when the object is not an instance of the expected parent class
--
function LuaUnitCustom.assertInstanceOf(_object, _class)

  local metaTable = getmetatable(_object);
  if (metaTable == nil) then
    error("The object is not an instance of the specified class");
  else

    local parentClass = metaTable.__index;
    if (parentClass ~= _class) then
      luaunit.assertInstanceOf(parentClass, _class);
    end

  end

end

---
-- Asserts that an error is thrown during a function execution.
--
-- @tparam string _expectedExceptionMessage The expected exception message
-- @tparam function _functionCall The function that throws the expected error
--
-- @raise Error when an unexpected exception message was thrown
-- @raise Error when no exception occurred
--
function LuaUnitCustom.assertError(_expectedExceptionMessage, _functionCall)

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


return LuaUnitCustom;
