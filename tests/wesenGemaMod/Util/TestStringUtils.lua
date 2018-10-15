---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--
local luaunit = require("tests/luaunit-custom");

local StringUtils = require("Util/StringUtils");

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

    -- Empty string
    { "", "a", { } },

    -- Single letter delimiter
    { "abacdaeafg", "a", { "b", "cd", "e", "fg" } },
    { "hello world", " ", { "hello", "world" } },
    { "Hel;lo;Univ;erse", ";", { "Hel", "lo", "Univ", "erse" } },

    -- Multi letter delimiter
    { "abcdebcfgbhbicjkbc", "bc", { "a", "de", "fgbhbicjk" } },

    -- Text ending with multiple delimiters in a row
    { "a b c   ", " " , { "a", "b", "c" } },

    -- Text starting with multiple delimiters in a row
    { "cccchelloctest", "c", {"hello", "test" } },

    -- Text containing multiple delimiters in a row
    { "good~~~~hello~~~mytest~", "~", { "good", "hello", "mytest" } }
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

---
-- Checks whether the split method can handle empty delimiters.
--
function TestStringUtils:testCanHandleEmptySplitString()

  luaunit.assertError(
    "The delimiter must contain at least one symbol.",
    function ()
      StringUtils:split("abc", "");
    end
  );

end
