---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Class that provides additional table functions.
--
-- @type TableUtils
--
local TableUtils = {};


-- Class Methods

---
-- Returns a part of a table from start index to end index.
--
-- @tparam table _table The table
-- @tparam int _startIndex The start index
-- @tparam int _endIndex The end index
--
-- @treturn table The partial table
--
function TableUtils:slice(_table, _startIndex, _endIndex)

  local length = #_table;

  -- Check and adjust start index
  if (tonumber(_startIndex) == nil or _startIndex < 1) then
    _startIndex = 1;
  elseif (_startIndex > length) then
    return {};
  end

  -- Check and adjust end index
  if (tonumber(_endIndex) == nil or _endIndex > length) then
    _endIndex = length;

  elseif (_endIndex < 0) then
    -- if end index is smaller than zero subtract that number from the table length
    _endIndex = length + _endIndex;

  end

  -- Create the result table
  local result = {};
  for index = _startIndex, _endIndex do
    table.insert(result, _table[index]);
  end

  return result;

end


---
-- Checks whether String _needle is contained in a table of strings.
--
-- @tparam string _needle The needle
-- @tparam string[] _haystack The haystack
--
-- @treturn bool True if the string was found in the table, false otherwise
--
function TableUtils:inTable(_needle, _haystack)

  for index, string in pairs(_haystack) do

    if (_needle == string) then
      return true;
    end

  end

  return false;

end

---
-- Returns the sum of values in a table.
--
-- @tparam int[] _table The table
--
-- @treturn int The sum of the values
--
function TableUtils:tableSum(_table)

  local sum = 0;

  for i, number in pairs(_table) do
    sum = sum + number;
  end

  return sum;

end

---
-- Returns the length of a table.
-- This function should only be used for associative tables because the length of tables with
-- numeric indexes starting from 1 and without any gaps can be fetched by using "#table"
--
-- @tparam table _associativeTable The table with associative indexes
--
-- @treturn int The length of the table
-- 
function TableUtils:getTableLength(_associativeTable)

  local numberOfElements = 0;
  for index, value in pairs(_associativeTable) do
    numberOfElements = numberOfElements + 1;
  end

  return numberOfElements;

end

---
-- Returns a clone of a table.
--
-- source: https://gist.github.com/tylerneylon/81333721109155b2d244
--
-- @tparam table obj The table
-- @tparam table seen The table that contains already seen tables
--
-- @treturn table Clone of the table
--
function TableUtils:copy(obj, seen)
  -- Handle non-tables and previously-seen tables.
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end

  -- New table; mark it as seen an copy recursively.
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[self:copy(k, s)] = self:copy(v, s) end
  return res
end

---
-- Returns whether an object is an instance of a class or one of its subclasses.
--
-- @tparam table _object The object
-- @tparam table _class The class
--
-- @treturn bool True if the object is an instance of the class or one of its subclasses, false otherwise
--
function TableUtils:isInstanceOf(_object, _class)

  local metaTable = getmetatable(_object)
  if (metaTable == nil) then
    return false;
  else

    local parentClass = metaTable.__index;
    if (tostring(parentClass) == tostring(_class)) then
      return true;
    else
      return self:isInstanceOf(parentClass, _class);
    end

  end

end


return TableUtils;
