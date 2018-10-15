---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require("Util/Exception");

---
-- Provides additional string functions.
--
-- @type StringUtils
--
local StringUtils = {};


-- Public Methods

---
-- Splits a string everytime the delimiter appears in it.
-- This function is based on the example from PeterPrade on http://lua-users.org/wiki/SplitJoin
--
-- @tparam string _text The string
-- @tparam string _delimiter The delimiter at which the string will be split
--
-- @treturn string[] The splits
--
function StringUtils:split(_text, _delimiter)

  if (_delimiter == "") then
    error(Exception("The delimiter must contain at least one symbol."));
  end

  local text = _text;
  local words = {};

  local stringPosition = 1
  while 1 do

    local delimiterStartPosition, delimiterEndPosition = text:find(_delimiter, stringPosition)

    -- Get the next word
    local word = "";
    if (delimiterStartPosition) then
      word = text:sub(stringPosition, delimiterStartPosition - 1);
      stringPosition = delimiterEndPosition + 1;
    else
      word = text:sub(stringPosition);
    end

    if (word ~= "") then
      table.insert(words, word);
    end

    if (not delimiterStartPosition) then
      break;
    end

  end

  return words;

end


return StringUtils;
