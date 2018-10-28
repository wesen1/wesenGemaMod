---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

--local mach = require("mach");

local DataBase = require("DataBase");
local MapRecord = require("Tops/MapTop/MapRecordList/MapRecord");
local MapRecordList = require("Tops/MapTop/MapRecordList/MapRecordList");
local MapTopLoader = require("Tops/MapTop/MapTopLoader");
local Player = require("Player/Player");
local TestCase = require("TestFrameWork/TestCase");

---
-- Checks whether the MapTopLoader works as expected.
--
local TestMapTopLoader = setmetatable({}, {__index = TestCase});


TestMapTopLoader.mapHandlerMock = nil;

TestMapTopLoader.mapTopLoader = nil;

TestMapTopLoader.mapRecordListMock = nil;

---
-- Method that is called before each test is executed.
--
function TestMapTopLoader:setUp()

  TestCase.setUp(self);

  -- Initialize the mocks
  self.mapHandlerMock = self:getDependencyMock(
    "Map/MapHandler", "Tops/MapTop/MapTopLoader", "MapHandlerMock"
  );
  MapTopLoader = require("Tops/MapTop/MapTopLoader");

  self.mapRecordListMock = self:getMock(MapRecordList, "MapRecordListMock");

  -- Initialize the map top loader test instance
  self.mapTopLoader = MapTopLoader();

end

---
-- Method that is called after each test is finished.
--
function TestMapTopLoader:tearDown()

  TestCase.tearDown(self);

  self.mapHandlerMock = nil;
  self.mapRecordListMock = nil;
  self.mapTopLoader = nil;

end


-- Fetch record tests

---
-- Checks whether map records for a map that does not exist in the database are fetched as expected.
--
function TestMapTopLoader:testCanFetchRecordsForNonExistingMap()

  local dataBaseMock = self:getMock(DataBase, "DataBaseMock");
  local testMapName = "not_a_map";

  -- Map name not found, return empty list
  self.mapRecordListMock.clear
                        :should_be_called()
                        :and_then(
                          self.mapHandlerMock.fetchMapId
                                             :should_be_called_with(
                                               dataBaseMock, testMapName
                                             )
                                             :and_will_return(nil)
                        )
                        :when(
                          function()
                            self.mapTopLoader:fetchRecords(
                              dataBaseMock, testMapName, self.mapRecordListMock
                            );
                          end
                        );

end

---
-- Checks whether an empty list of map records can be fetched for a map that does exist in the database.
--
function TestMapTopLoader:testCanFetchEmptyRecordListForExistingMap()

  local dataBaseMock = self:getMock(DataBase, "DataBaseMock");
  local testMapName = "pro_map";

  -- No records in database for this map
  local expectedQuery = "SELECT milliseconds, weapon_id, team_id, UNIX_TIMESTAMP(created_at) as created_at_timestamp, players.id, names.name, ips.ip "
           .. "FROM records "
           .. "INNER JOIN maps ON records.map = maps.id "
           .. "INNER JOIN players ON records.player = players.id "
           .. "INNER JOIN names ON players.name = names.id "
           .. "INNER JOIN ips ON players.ip = ips.id "
           .. "WHERE maps.id = 5 "
           .. "ORDER BY milliseconds ASC;";

  self.mapRecordListMock.clear
                        :should_be_called()
                        :and_then(
                          self.mapHandlerMock.fetchMapId
                                             :should_be_called_with(dataBaseMock, testMapName)
                                             :and_will_return(5)
                        ):and_then(
                          dataBaseMock.query
                                      :should_be_called_with(expectedQuery, true)
                                      :and_will_return({})
                       )
                       :when(
                         function()
                           self.mapTopLoader:fetchRecords(
                             dataBaseMock, testMapName, self.mapRecordListMock
                           );
                         end
                       );

end


---
-- Checks whether a list of multiple map records can be fetched for a existing map.
--
function TestMapTopLoader:testCanFetchRecordListForExistingMap()

  local dataBaseMock = self:getMock(DataBase, "DataBaseMock");
  local testMapName = "noob_map";

  -- Some records in database for this map
  local expectedQuery = "SELECT milliseconds, weapon_id, team_id, UNIX_TIMESTAMP(created_at) as created_at_timestamp, players.id, names.name, ips.ip "
           .. "FROM records "
           .. "INNER JOIN maps ON records.map = maps.id "
           .. "INNER JOIN players ON records.player = players.id "
           .. "INNER JOIN names ON players.name = names.id "
           .. "INNER JOIN ips ON players.ip = ips.id "
           .. "WHERE maps.id = 7 "
           .. "ORDER BY milliseconds ASC;";

  local testDataBaseEntries = {
    {
      ["milliseconds"] = "5012",
      ["weapon_id"] = "2",
      ["team_id"] = "1",
      ["created_at_timestamp"] = "1235123",
      ["id"] = "1",
      ["name"] = "trottel",
      ["ip"] = "127.0.0.1"
    },
    {
      ["milliseconds"] = "7034",
      ["weapon_id"] = "3",
      ["team_id"] = "1",
      ["created_at_timestamp"] = "12351232",
      ["id"] = "2",
      ["name"] = "trottelB",
      ["ip"] = "127.0.0.1"
    },
    {
      ["milliseconds"] = "25740",
      ["weapon_id"] = "4",
      ["team_id"] = "1",
      ["created_at_timestamp"] = "123512314",
      ["id"] = "3",
      ["name"] = "trottelC",
      ["ip"] = "127.0.0.1"
    }
  }

  local expectedPlayerA = Player("trottel", "127.0.0.1");
  local expectedPlayerB = Player("trottelB", "127.0.0.1");
  local expectedPlayerC = Player("trottelC", "127.0.0.1");

  expectedPlayerA:setId(1);
  expectedPlayerB:setId(2);
  expectedPlayerC:setId(3);

  local expectedMapRecordA = MapRecord(expectedPlayerA, 5012, 2, 1, self.mapTopMock, 1);
  local expectedMapRecordB = MapRecord(expectedPlayerB, 7034, 3, 1, self.mapTopMock, 2);
  local expectedMapRecordC = MapRecord(expectedPlayerC, 25740, 4, 1, self.mapTopMock, 3);

  expectedMapRecordA:setCreatedAt(1235123);
  expectedMapRecordB:setCreatedAt(12351232);
  expectedMapRecordC:setCreatedAt(123512314);


  local expectedRecordsList = { expectedMapRecordA, expectedMapRecordB, expectedMapRecordC }
  local mapRecordId = 1;

  local function addRecordMatcher(_addedMapRecord, _expectedMapRecord)
    mapRecordId = mapRecordId + 1;
    return _addedMapRecord:equals(_expectedMapRecord);
  end

  self.mapRecordListMock.clear
                        :should_be_called()
                        :and_then(
                          self.mapHandlerMock.fetchMapId
                                             :should_be_called_with(dataBaseMock, testMapName)
                                             :and_will_return(7)
                        ):and_then(
                          dataBaseMock.query
                                      :should_be_called_with(expectedQuery, true)
                                      :and_will_return(testDataBaseEntries)
                        ):and_then(
                          self.mapRecordListMock.addRecord
                                                :should_be_called_with_any_arguments()
                                                --[[:should_be_called_with(
                                                  mach.match(
                                                    expectedRecordsList[mapRecordId],
                                                    addRecordMatcher
                                                  )
                                                )--]]
                                                :multiple_times(3)--]]
                        ):when(
                          function()

                            self.mapTopLoader:fetchRecords(
                              dataBaseMock, testMapName, self.mapRecordListMock
                            );

                            --for index, record in ipairs(records) do
                              --self.assertTrue(record:equals(expectedRecordsList[index]));
                           -- end

                         end
                       );

end

--@todo: Fix check which map records are added
--@todo: Add test for single map record returned

return TestMapTopLoader;
