---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Provides additional table functions.
--
-- @type TableUtils
--
local TableUtils = {};


-- Public Methods

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
    -- If the end index is smaller than zero subtract that number from the table length
    _endIndex = length + _endIndex;

  end

  -- Create the result table
  local result = {};
  for index = _startIndex, _endIndex, 1 do
    table.insert(result, _table[index]);
  end

  return result;

end

---
-- Returns whether a table contains a specific value.
--
-- @tparam table _table The table to search in
-- @tparam mixed _value The value to search for
--
-- @treturn bool True if the table contains the value, false otherwise
--
function TableUtils.tableHasValue(_table, _value)

  for _, value in pairs(_table) do
    if (value == _value) then
      return true
    end
  end

  return false

end


return TableUtils;
