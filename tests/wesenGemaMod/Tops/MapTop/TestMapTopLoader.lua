---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local luaunit = require("tests/luaunit-custom");
local mach = require("mach");

local MapHandler = require("Map/MapHandler");

local mapHandlerMock = mach.mock_object(MapHandler, "MapHandlerMock");
package.loaded["Map/MapHandler"] = mapHandlerMock;
package.loaded["Tops/MapTop/MapTopLoader"] = nil;

local DataBase = require("DataBase");
local MapTop = require("Tops/MapTop/MapTop");
local MapTopLoader = require("Tops/MapTop/MapTopLoader");
local MapRecord = require("Tops/MapTop/MapRecordList/MapRecord");
local Player = require("Player/Player");


---
-- Checks whether the MapTopLoader works as expected.
--
local TestMapTopLoader = {};


---
-- Method that is called before each test is executed.
--
function TestMapTopLoader:setUp()

  self.mapTopMock = mach.mock_object(MapTop, "MapTopMock");
  self.mapTopLoader = MapTopLoader:__construct(self.mapTopMock);

end

---
-- Method that is called after each test is finished.
--
function TestMapTopLoader:tearDown()

  self.mapTopMock = nil;
  self.mapTopLoader = nil;

end


---
-- Checks whether the getters/setters work as expected.
--
function TestMapTopLoader:testCanGetAttributes()

  local mapTopMock = mach.mock_object(MapTop, "TestMapTopMock");

  self.mapTopLoader:setParentMapTop(mapTopMock);
  luaunit.assertEquals(self.mapTopLoader:getParentMapTop(), mapTopMock);

end

---
-- Checks whether the maptop loader can fetch records as expected.
--
function TestMapTopLoader:testCanFetchRecords()

  local dataBaseMock = mach.mock_object(DataBase, "DataBaseMock");
  local expectedQuery = "";

  -- Map name not found
  mapHandlerMock.fetchMapId
                :should_be_called_with(dataBaseMock, "not_a_map")
                :and_will_return(nil)
                :when(
                  function ()
                    local records = self.mapTopLoader:fetchRecords(dataBaseMock, "not_a_map");
                    luaunit.assertEquals(records, {});
                  end
                );


  -- No records in database for this map
  expectedQuery = "SELECT milliseconds, weapon_id, team_id, UNIX_TIMESTAMP(created_at) as created_at_timestamp, players.id, names.name, ips.ip "
           .. "FROM records "
           .. "INNER JOIN maps ON records.map = maps.id "
           .. "INNER JOIN players ON records.player = players.id "
           .. "INNER JOIN names ON players.name = names.id "
           .. "INNER JOIN ips ON players.ip = ips.id "
           .. "WHERE maps.id = 5 "
           .. "ORDER BY milliseconds ASC;";

  mapHandlerMock.fetchMapId
                :should_be_called_with(dataBaseMock, "pro_map")
                :and_will_return(5)
                :and_then(
                  dataBaseMock.query
                              :should_be_called_with(expectedQuery, true)
                              :and_will_return({})
                )
                :when(
                  function ()
                    local records = self.mapTopLoader:fetchRecords(dataBaseMock, "pro_map");
                    luaunit.assertEquals(records, {});
                  end
                );


  -- Some records in database for this map
  expectedQuery = "SELECT milliseconds, weapon_id, team_id, UNIX_TIMESTAMP(created_at) as created_at_timestamp, players.id, names.name, ips.ip "
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

  local expectedPlayerA = Player:__construct("trottel", "127.0.0.1");
  local expectedPlayerB = Player:__construct("trottelB", "127.0.0.1");
  local expectedPlayerC = Player:__construct("trottelC", "127.0.0.1");

  expectedPlayerA:setId(1);
  expectedPlayerB:setId(2);
  expectedPlayerC:setId(3);

  local expectedMapRecordA = MapRecord:__construct(expectedPlayerA, 5012, 2, 1, self.mapTopMock, 1);
  local expectedMapRecordB = MapRecord:__construct(expectedPlayerB, 7034, 3, 1, self.mapTopMock, 2);
  local expectedMapRecordC = MapRecord:__construct(expectedPlayerC, 25740, 4, 1, self.mapTopMock, 3);

  expectedMapRecordA:setCreatedAt(1235123);
  expectedMapRecordB:setCreatedAt(12351232);
  expectedMapRecordC:setCreatedAt(123512314);


  local expectedRecordsList = { expectedMapRecordA, expectedMapRecordB, expectedMapRecordC }

  mapHandlerMock.fetchMapId
                :should_be_called_with(dataBaseMock, "noob_map")
                :and_will_return(7)
                :and_then(
                  dataBaseMock.query
                              :should_be_called_with(expectedQuery, true)
                              :and_will_return(testDataBaseEntries)
                )
                :when(
                  function ()
                    local records = self.mapTopLoader:fetchRecords(dataBaseMock, "noob_map");

                    for index, record in ipairs(records) do
                      luaunit.assertTrue(record:equals(expectedRecordsList[index]));
                    end

                  end
                );

end

-- Restore real dependencies
package.loaded["Map/MapHandler"] = require("Map/MapHandler");


return TestMapTopLoader;
