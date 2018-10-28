---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Provides object related util functions.
--
-- @type ObjectUtils
--
local ObjectUtils = {};


-- Public Methods

---
-- Returns a clone of an object.
--
-- This function is based on the copy3 function from tylerneylon
-- @see https://gist.github.com/tylerneylon/81333721109155b2d244
--
-- @tparam table _object The object
-- @tparam table _clonedObjects The list of already cloned sub objects
--
-- @treturn table The clone of the table
--
function ObjectUtils:clone(_object, _clonedObjects)

  -- If the object is not a table, return the raw data (number, string, bool, ect.)
  if (type(_object) ~= "table") then
    return _object;
  end

  -- If the object was already cloned in another cycle of this method, return the already cloned object
  if (_clonedObjects and _clonedObjects[_object]) then
    return _clonedObjects[_object]
  end


  -- The table is a new table

  -- Initialize the list of already cloned objects
  local clonedObjects = {};
  if (_clonedObjects) then
    clonedObjects = _clonedObjects;
  end

  -- Create an empty object with the same meta table like the target object
  local clonedObject = setmetatable({}, getmetatable(_object));

  -- Add the new cloned object to the list of already cloned objects
  clonedObjects[_object] = clonedObject;

  -- Iterate over all properties of the object
  for propertyIndex, propertyValue in pairs(_object) do

    local clonedPropertyIndex = self:clone(propertyIndex, clonedObjects);
    local clonedPropertyValue = self:clone(propertyValue, clonedObjects);

    clonedObject[clonedPropertyIndex] = clonedPropertyValue;

  end

  return clonedObject;

end

---
-- Returns whether an object is an instance of a class or one of its subclasses.
--
-- @tparam table _object The object
-- @tparam table _class The class
--
-- @treturn bool True if the object is an instance of the class or one of its subclasses, false otherwise
--
function ObjectUtils:isInstanceOf(_object, _class)

  local metaTable = getmetatable(_object);
  if (metaTable == nil) then
    return false;
  else

    local parentClass = metaTable.__index;
    if (parentClass == _class) then
      return true;
    else
      return self:isInstanceOf(parentClass, _class);
    end

  end

end


return ObjectUtils;
