---
-- Table functions
--

---
-- Returns a part of a table from start index to end index.
--
-- @param _table (table) The table
-- @param _startIndex (int) Start index
-- @param _endIndex (int) End index
--
-- @return (table) The partial table
--
function slice(_table, _startIndex, _endIndex)

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


  local result = {};
  for index = _startIndex, _endIndex do
    table.insert(result, _table[index]);
  end

  return result;

end

---
-- Checks whether String _needle is contained in a table of strings.
--
-- @param _needle (String) Needle
-- @param _haystack (String[]) Haystack
--
-- @return (bool) True: String was found int table
--                False: String was not found in table
--
function in_table(_needle, _haystack)

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
-- @param obj (table) The table
-- @param seen (table) Table containing already seen table
--
-- @return (table) Clone of the table
--
function copy(obj, seen)
  -- Handle non-tables and previously-seen tables.
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end

  -- New table; mark it as seen an copy recursively.
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end


---
-- String functions
--

---
-- Splits a string everytime the delimiter appears in it.
--
-- @param _text (String) The string
-- @param _delimiter (String) Delimiter at which the string will be split
--
-- @return (table) The splits
--
function split(_text, _delimiter)

  text = _text .. _delimiter;
  words = {};

  for word in text:gmatch("([^" .. _delimiter .. "]*)" .. _delimiter) do

    if (#word > 0) then
      table.insert(words, word);
    end

  end

  return words;

end
