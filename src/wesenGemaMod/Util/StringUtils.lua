---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Class that provides additional string functions.
--
-- @type StringUtils
--
local StringUtils = {};


-- Class Methods

---
-- Splits a string everytime the delimiter appears in it.
--
-- @tparam string _text The string
-- @tparam string _delimiter The delimiter at which the string will be split
--
-- @treturn string[] The splits
--
function StringUtils:split(_text, _delimiter)

  local text = _text .. _delimiter;
  local words = {};

  for word in text:gmatch("([^" .. _delimiter .. "]*)" .. _delimiter) do

    if (#word > 0) then
      table.insert(words, word);
    end

  end

  return words;

end


return StringUtils;
