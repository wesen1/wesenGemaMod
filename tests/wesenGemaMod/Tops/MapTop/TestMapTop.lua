---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local DataBase = require("DataBase");
local MapRecord = require("Tops/MapTop/MapRecordList/MapRecord");
local MapRecordList = require("Tops/MapTop/MapRecordList/MapRecordList");
local MapTop = require("Tops/MapTop/MapTop");
local MapTopLoader = require("Tops/MapTop/MapTopLoader");
local MapTopSaver = require("Tops/MapTop/MapTopSaver");
local TestCase = require("TestFrameWork/TestCase");

---
-- Checks whether the MapTop class works as expected.
--
-- @type TestMapTop
--
local TestMapTop = setmetatable({}, {__index = TestCase});


---
-- The map top test instance
--
-- @tfield MapTop mapTop
--
TestMapTop.mapTop = nil;


-- Public Methods

---
-- Method that is called before each test is executed.
--
function TestMapTop:setUp()
  TestCase.setUp(self);
  self.mapTop = MapTop();
end

---
-- Method that is called after each test is finished.
--
function TestMapTop:tearDown()
  TestCase.tearDown(self);
  self.mapTop = nil;
end


---
-- Checks whether the constructor works as expected.
--
function TestMapTop:testCanBeConstructed()

  local mapTop = MapTop();

  self.assertInstanceOf(mapTop.mapRecordList, MapRecordList);
  self.assertInstanceOf(mapTop.mapTopLoader, MapTopLoader);
  self.assertInstanceOf(mapTop.mapTopSaver, MapTopSaver);

end

---
-- Checks whether the getters work as expected.
--
function TestMapTop:canGetProperties()

  local mapRecordListMock = self:getMock(MapRecordList, "MapRecordListMock");
  self.mapTop.mapRecordList = mapRecordListMock;

  self.assertEquals(self.mapTop:getMapRecordList(), mapRecordListMock);

end

---
-- Checks whether records are added as expected.
--
function TestMapTop:testCanAddRecords()

  local dataBaseMock = self:getMock(DataBase, "DataBaseMock");
  local mapRecordListMock = self:getMock(MapRecordList, "MapRecordListMock");
  local mapTopSaverMock = self:getMock(MapTopSaver, "MapTopSaverMock");
  local mapRecordMock = self:getMock(MapRecord, "MapRecordMock");

  self.mapTop.mapRecordList = mapRecordListMock;
  self.mapTop.mapTopSaver = mapTopSaverMock;
  self.mapTop.lastMapName = "last-map-name";


  -- No personal best time, do nothing
  mapRecordListMock.isPersonalBestTime
                   :should_be_called_with(mapRecordMock)
                   :and_will_return(false)
                   :when(
                     function()
                       self.mapTop:addRecord(dataBaseMock, mapRecordMock);
                     end
                   );

  -- New personal best time, add the record to the map record list and the map top saver
  mapRecordListMock.isPersonalBestTime
                   :should_be_called_with(mapRecordMock)
                   :and_will_return(true)
                   :and_then(
                     mapRecordListMock.addRecord
                                      :should_be_called_with(mapRecordMock)
                   ):and_then(
                     mapTopSaverMock.addRecord
                                    :should_be_called_with(
                                      dataBaseMock, mapRecordMock, "last-map-name"
                                    )
                   ):when(
                     function()
                       self.mapTop:addRecord(dataBaseMock, mapRecordMock);
                     end
                   );

end

---
-- Checks whether the maptop can load the records for a map.
--
function TestMapTop:testCanLoadRecords()

  local dataBaseMock = self:getMock(DataBase, "DataBaseMock");
  local mapRecordListMock = self:getMock(MapRecordList, "MapRecordListMock");
  local mapTopLoaderMock = self:getMock(MapTopLoader, "MapTopLoaderMock");

  self.mapTop.mapRecordList = mapRecordListMock;
  self.mapTop.mapTopLoader = mapTopLoaderMock;
  self.mapTop.lastMapName = nil;

  -- No last map name, fetch the records
  local testMapName = "pro_gema";

  mapTopLoaderMock.fetchRecords
                  :should_be_called_with(dataBaseMock, testMapName, mapRecordListMock)
                  :when(
                    function()
                      self.mapTop:loadRecords(dataBaseMock, testMapName);
                      self.assertEquals(self.mapTop.lastMapName, testMapName);
                    end
                  );

  -- Different map name than last map name, fetch the records
  testMapName = "other_gema";

  mapTopLoaderMock.fetchRecords
                  :should_be_called_with(dataBaseMock, testMapName, mapRecordListMock)
                  :when(
                    function()
                      self.mapTop:loadRecords(dataBaseMock, testMapName);
                      self.assertEquals(self.mapTop.lastMapName, testMapName);
                    end
                  );

  -- Same map name like last map name, do nothing
  self.mapTop:loadRecords(dataBaseMock, testMapName);
  self.assertEquals(self.mapTop.lastMapName, testMapName);

end


return TestMapTop;
