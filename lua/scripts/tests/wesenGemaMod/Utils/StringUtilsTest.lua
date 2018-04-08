---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--
local luaunit = require("luaunit");
local StringUtils = require("Utils/StringUtils");


---
-- Checks whether the string utils work as expected.
--
-- @type TestStringUtils
--
TestStringUtils = {};

---
-- Checks whether the split function works as expected.
--
function TestStringUtils:testCanSplitStringByDelimiter()

  local testValues = {

    { "abacdaeafg", "a", { "b", "cd", "e", "fg" } },
    { "hello world", " ", { "hello", "world" } },
    { "Hel;lo;Univ;erse", ";", { "Hel", "lo", "Univ", "erse" } },

    -- Delimiter with more than one symbol
    { "abcdebcghallobc", "bc", { "a", "de", "ghallo" } },

    -- Text ending with delimiters
    { "a b c   ", " " , { "a", "b", "c" } }
  }

  for index, testValueSet in ipairs(testValues) do
    self:canSplitStringByDelimiter(unpack(testValueSet));
  end

end

---
-- Checks one of the data sets of testCanSplitStringByDelimiter.
--
-- @tparam string _text The text that will be split
-- @tparam string _delimiter The delimiter by which the text will be split
-- @tparam string[] _expectedResult The expected result
--
function TestStringUtils:canSplitStringByDelimiter(_text, _delimiter, _expectedResult)

  local result = StringUtils:split(_text, _delimiter);
  luaunit.assertEquals(result, _expectedResult);

end
