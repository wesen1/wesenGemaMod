---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TableUtils = require("Util/TableUtils");
local TestCase = require("TestFrameWork/TestCase");

---
-- Checks whether the table utils work as expected.
--
-- @type TestTableUtils
--
local TestTableUtils = setmetatable({}, {__index = TestCase});


---
-- Checks whether the slice method works as expected.
--
function TestTableUtils:testCanSliceTable()

  local testValues = {

    -- Start index < 1
    { 0, 1, { 1 } },

    -- Start index = not a number
    { "g", 2, { 1, 2 } },

    -- Start index = nil
    { nil, 3, { 1, 2, 3 } },


    -- End index > length
    { 3, 10, { 3, 4, 5 } },

    -- Start index > length
    { 17, 20, { } },

    -- End index = not a number
    { 2, "g", { 2, 3, 4, 5 } },

    -- End index = negative number
    { 2, -1, { 2, 3, 4 } }
  }

  for index, testValueSet in ipairs(testValues) do
    self:canSliceTable(unpack(testValueSet));
  end

end

---
-- Checks one of the data sets of testCanSliceTable.
--
-- @tparam int _startIndex The start index
-- @tparam int _endIndex The end index
-- @tparam bool _expectedResult The expected result
--
function TestTableUtils:canSliceTable(_startIndex, _endIndex, _expectedResult)

  local testTable = { 1, 2, 3, 4, 5 };

  local resultingTable = TableUtils:slice(testTable, _startIndex, _endIndex);
  self.assertEquals(resultingTable, _expectedResult);

end


return TestTableUtils;
