---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local StringUtils = require("Util/StringUtils");
local TestCase = require("TestFrameWork/TestCase");

---
-- Checks whether the string utils work as expected.
--
-- @type TestStringUtils
--
local TestStringUtils = setmetatable({}, {__index = TestCase});


---
-- Checks whether the split function works as expected.
--
function TestStringUtils:testCanSplitStringByDelimiter()

  local testValues = {

    -- Empty string
    { "", "a", { } },

    -- Empty delimiter
    { "abc", "", { "a", "b", "c" } },

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
  self.assertEquals(result, _expectedResult);

end


return TestStringUtils;
