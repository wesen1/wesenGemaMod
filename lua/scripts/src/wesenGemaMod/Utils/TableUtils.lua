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
    _startIndex = length;

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
-- @treturn bool True: String was found in the table
--               False: String was not found in the table
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


return TableUtils;
