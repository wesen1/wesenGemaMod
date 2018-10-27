---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

--@todo: Force constructor on this class too

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
-- @tparam bool _keepEmptyTextParts If set to true empty text parts will be included in the result
--
-- @treturn string[] The splits
--
function StringUtils:split(_text, _delimiter, _keepEmptyTextParts)

  if (_delimiter == "") then
    -- Split the string into characters
    local characters = {};

    for character in _text:gmatch(".") do
      table.insert(characters, character);
    end

    return characters;

  else
    -- Split the string into words with the delimiter

    local text = _text;
    local words = {};

    local stringPosition = 1;
    while (true) do

      local delimiterStartPosition, delimiterEndPosition = text:find(_delimiter, stringPosition)

      -- Get the next word
      local word;
      if (delimiterStartPosition) then
        word = text:sub(stringPosition, delimiterStartPosition - 1);
        stringPosition = delimiterEndPosition + 1;
      else
        word = text:sub(stringPosition);
      end

      if (_keepEmptyTextParts or word ~= "") then
        table.insert(words, word);
      end

      if (not delimiterStartPosition) then
        break;
      end

    end

    return words;

  end

end


return StringUtils;
