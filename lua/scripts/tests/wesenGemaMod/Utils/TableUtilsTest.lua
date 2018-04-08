---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--
local luaunit = require("luaunit");
local TableUtils = require("Utils/TableUtils");


---
-- Checks whether the table utils work as expected.
--
-- @type TestTableUtils
--
TestTableUtils = {};

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

    -- Start index and end index > length
    { 17, 20, { 5 } },

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
-- @tparam Bool _expectedResult The expected result
--
function TestTableUtils:canSliceTable(_startIndex, _endIndex, _expectedResult)

  local testTable = { 1, 2, 3, 4, 5 };

  local resultingTable = TableUtils:slice(testTable, _startIndex, _endIndex);
  luaunit.assertEquals(resultingTable, _expectedResult);

end

---
-- Checks whether the inTable method works as expected.
--
function TestTableUtils:testCanDetectElementInTable()

  local testValues = {

    -- Characters
    { { "a", "b", "c" }, "A", false },
    { { "a", "b", "c" }, "a", true },
    { { "a", "b", "c" }, "d", false },

    -- Numbers
    { { 1, 2, 3 }, 1, true },
    { { 1, 2, 3 }, 0, false },
    { { 1, 2, 3 }, 4, false }

  };

  for index, testValueSet in ipairs(testValues) do
    self:canDetectElementInTable(unpack(testValueSet));
  end

end

---
-- Checks one of the data sets of testCanDetectElementInTable.
--
-- @tparam string[] _table The table
-- @tparam string _element The element that shall be found in the table
-- @tparam Bool _expectedReturnValue The expected return value
--
function TestTableUtils:canDetectElementInTable(_table, _element, _expectedReturnValue)

  local result = TableUtils:inTable(_element, _table);
  luaunit.assertEquals(result, _expectedReturnValue);

end

---
-- Checks whether the tableSum method works as expected.
--
function TestTableUtils:testCanCalculateTableSum()

  local testValues = {
    { { 1, 2, 3 }, 6 },
    { { 4, 3, 7 }, 14 },
    { { 2, 8, 7 }, 17 },
    { { 3, 4, 5, 6 }, 18 },
    { { 1, 2 }, 3 }
  }

  for index, testValueSet in ipairs(testValues) do
    self:canCalculateTableSum(unpack(testValueSet));
  end

end

---
-- Checks one of the data sets of testCanCalculateTableSum.
--
-- @tparam int[] _table The table of numbers
-- @tparam int _expectedSum The expected table sum
--
function TestTableUtils:canCalculateTableSum(_table, _expectedSum)

  local sum = TableUtils:tableSum(_table);
  luaunit.assertEquals(sum, _expectedSum);

end

---
-- Checks whether the copy method works as expected.
--
function TestTableUtils:testCanCopyTable()

  local testTable = {
    ["name"] = "gema",
    ["rank"] = 1,
    ["points"] = 1000000
  }

  -- Check that changing a reference also changes the source table
  local testTableReference = testTable;
  luaunit.assertEquals(testTable, testTableReference);

  testTableReference["name"] = "notgema";
  testTableReference["rank"] = 999;
  testTableReference["points"] = 0;

  luaunit.assertEquals(testTable["name"], "notgema");
  luaunit.assertEquals(testTable["rank"], 999);
  luaunit.assertEquals(testTable["points"], 0);

  -- Check that changing a copied table does not change the source table
  local testTableCopy = TableUtils:copy(testTable);
  luaunit.assertEquals(testTable, testTableCopy);

  testTableCopy["name"] = "tdm";
  testTableCopy["rank"] = 10000;
  testTableCopy["points"] = -500;

  luaunit.assertEquals(testTable["name"], "notgema");
  luaunit.assertEquals(testTable["rank"], 999);
  luaunit.assertEquals(testTable["points"], 0);

end
