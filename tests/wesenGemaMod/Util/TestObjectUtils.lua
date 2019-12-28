---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ObjectUtils = require("Util/ObjectUtils");
local TestCase = require("TestFrameWork/TestCase");

---
-- Checks whether the object utils work as expected.
--
-- @type TestObjectUtils
--
local TestObjectUtils = setmetatable({}, {__index = TestCase});


---
-- Checks whether the copy method works as expected.
--
function TestObjectUtils:testCanCopyTable()

  local testTable = {
    ["name"] = "gema",
    ["rank"] = 1,
    ["points"] = 1000000
  };

  -- Check that changing a reference also changes the source table
  local testTableReference = testTable;
  self.assertEquals(testTable, testTableReference);
  self.assertEquals(tostring(testTable), tostring(testTableReference));

  testTableReference["name"] = "notgema";
  testTableReference["rank"] = 999;
  testTableReference["points"] = 0;

  self.assertEquals(testTable["name"], "notgema");
  self.assertEquals(testTable["rank"], 999);
  self.assertEquals(testTable["points"], 0);

  -- Check that changing a copied table does not change the source table
  local testTableCopy = ObjectUtils:clone(testTable);
  self.assertEquals(testTable, testTableCopy);
  self.assertNotEquals(tostring(testTable), tostring(testTableCopy));

  testTableCopy["name"] = "tdm";
  testTableCopy["rank"] = 10000;
  testTableCopy["points"] = -500;

  self.assertEquals(testTable["name"], "notgema");
  self.assertEquals(testTable["rank"], 999);
  self.assertEquals(testTable["points"], 0);

end


return TestObjectUtils;
