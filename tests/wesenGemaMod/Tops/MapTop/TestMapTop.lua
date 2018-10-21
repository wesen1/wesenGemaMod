---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local luaunit = require("tests/luaunit-custom");
local mach = require("mach");

local GemaMode = require("GemaMode");
local MapTop = require("Tops/MapTop/MapTop");
local MapRecordList = require("Tops/MapTop/MapRecordList/MapRecordList");
local MapTopLoader = require("Tops/MapTop/MapTopLoader");
local MapTopPrinter = require("Tops/MapTop/MapTopPrinter");
local MapTopSaver = require("Tops/MapTop/MapTopSaver");
local MapRecord = require("Tops/MapTop/MapRecordList/MapRecord");
local Player = require("Player/Player");

---
-- Checks whether the MapTop class works as expected.
--
-- @type TestMapTop
--
local TestMapTop = {};


---
-- Method that is called before each test is executed.
--
function TestMapTop:setUp()

  self.gemaModMock = mach.mock_object(GemaMod, "GemaModMock");
  self.mapTop = MapTop:__construct(self.gemaModMock);
  self.mapTop:setMapName("gema_for_pros");

end

---
-- Method that is called after each test is finished.
--
function TestMapTop:tearDown()

  self.gemaModMock = nil;
  self.mapTop = nil;

end

---
-- Checks whether the getters/setters work as expected.
--
function TestMapTop:testCanGetAttributes()

  local gemaModMock = mach.mock_object(GemaMod, "GemaModMock");
  local mapName = "test_gema";
  local mapTopCacherMock = mach.mock_object(MapTopCacher, "MapTopCacherMock");
  local mapTopLoaderMock = mach.mock_object(MapTopLoader, "MapTopLoaderMock");
  local mapTopPrinterMock = mach.mock_object(MapTopPrinter, "MapTopPrinterMock");
  local mapTopSaverMock = mach.mock_object(MapTopSaver, "MapTopSaverMock");

  self.mapTop:setParentGemaMod(gemaModMock);
  self.mapTop:setMapName("test_gema");
  self.mapTop:setMapTopCacher(mapTopCacherMock);
  self.mapTop:setMapTopLoader(mapTopLoaderMock);
  self.mapTop:setMapTopPrinter(mapTopPrinterMock);
  self.mapTop:setMapTopSaver(mapTopSaverMock);

  luaunit.assertEquals(self.mapTop:getParentGemaMod(), gemaModMock);
  luaunit.assertEquals(self.mapTop:getMapName(), mapName);
  luaunit.assertEquals(self.mapTop:getMapTopCacher(), mapTopCacherMock);
  luaunit.assertEquals(self.mapTop:getMapTopLoader(), mapTopLoaderMock);
  luaunit.assertEquals(self.mapTop:getMapTopPrinter(), mapTopPrinterMock);
  luaunit.assertEquals(self.mapTop:getMapTopSaver(), mapTopSaverMock);

end

---
-- Checks whether records are added as expected.
--
function TestMapTop:testCanAddRecords()

  local mapTopCacherMock = mach.mock_object(MapTopCacher, "MapTopCacherMock");
  local mapTopSaverMock = mach.mock_object(MapTopSaver, "MapTopSaverMock");

  self.mapTop:setMapTopCacher(mapTopCacherMock);
  self.mapTop:setMapTopSaver(mapTopSaverMock);

  local testPlayerNew = Player:__construct("testplayer", "10.0.0.0");
  local testPlayerExisting = Player:__construct("testplayer", "10.0.0.0");

  local newMapRecord = MapRecord:__construct(testPlayerNew, 12300, GUN_SUBGUN, TEAM_RVSF, self.maptop, 2);
  local existingMapRecord = MapRecord:__construct(
    testPlayerExisting, 12100, GUN_KNIFE, TEAM_RVSF, self.maptop, 1
  );


  -- No existing record: Save the record
  mapTopCacherMock.getRecordByPlayer
                  :should_be_called_with(testPlayerNew)
                  :and_will_return(nil)
                  :and_then(
                    mapTopCacherMock.addRecord
                                    :should_be_called_with(newMapRecord, nil)
                  )
                  :and_then(
                    self.gemaModMock.getDataBase
                                    :should_be_called()
                                    :and_will_return("database")
                  )
                  :and_then(
                    mapTopSaverMock.addRecord
                                   :should_be_called_with("database", newMapRecord, "gema_for_pros")
                  )
                  :when(
                    function()
                      self.mapTop:addRecord(newMapRecord);
                    end
                  );


  -- Existing record is better than new record: No change
  existingMapRecord:setMilliseconds(newMapRecord:getMilliseconds() - 1);
  existingMapRecord:setRank(1);
  newMapRecord:setRank(2);

  mapTopCacherMock.getRecordByPlayer
                  :should_be_called_with(testPlayerNew)
                  :and_will_return(existingMapRecord)
                  :when(
                    function()
                      self.mapTop:addRecord(newMapRecord);
                    end
                  );

  -- Existing record is equal to the new record: No change
  existingMapRecord:setMilliseconds(newMapRecord:getMilliseconds());
  existingMapRecord:setRank(1);
  newMapRecord:setRank(2);

  mapTopCacherMock.getRecordByPlayer
                  :should_be_called_with(testPlayerNew)
                  :and_will_return(existingMapRecord)
                  :when(
                    function()
                      self.mapTop:addRecord(newMapRecord);
                    end
                  );

  -- Existing record is worse than the new record: Update record
  existingMapRecord:setMilliseconds(newMapRecord:getMilliseconds() + 1)
  existingMapRecord:setRank(1);
  newMapRecord:setRank(1);

  mapTopCacherMock.getRecordByPlayer
                  :should_be_called_with(testPlayerNew)
                  :and_will_return(existingMapRecord)
                  :and_then(
                    mapTopCacherMock.addRecord
                                    :should_be_called_with(newMapRecord, 1)
                  )
                  :and_then(
                    self.gemaModMock.getDataBase
                                    :should_be_called()
                                    :and_will_return("database")
                  )
                  :and_then(
                    mapTopSaverMock.addRecord
                                   :should_be_called_with("database", newMapRecord, "gema_for_pros")
                  )
                  :when(
                    function ()
                      self.mapTop:addRecord(newMapRecord);
                    end
                  );

end

---
-- Checks whether the rank of a player can be retrieved by the players name.
--
function TestMapTop:testCanGetRank()

  local mapTopCacherMock = mach.mock_object(MapRecordList, "MapRecordListMock");
  self.mapTop:setMapTopCacher(mapTopCacherMock);

  local testPlayer = Player:__construct("pro", "123.123.123.123");

  -- No record
  mapTopCacherMock.getRecordByPlayer
                  :should_be_called_with(testPlayer)
                  :and_will_return(nil)
                  :when(
                    function()
                      local rank = self.mapTop:getRank(testPlayer);
                      luaunit.assertNil(rank);
                    end
                  );

  -- Existing record
  local existingRecord = MapRecord:__construct(
    testPlayer, 13143, GUN_SUBGUN, TEAM_CLA, self.mapTop, 7
  );

  mapTopCacherMock.getRecordByPlayer
                  :should_be_called_with(testPlayer)
                  :and_will_return(existingRecord)
                  :when(
                    function ()
                      local rank = self.mapTop:getRank(testPlayer);
                      luaunit.assertEquals(rank, 7);
                    end
                  );

end

---
-- Checks whether the maptop can get records by rank as expected.
--
function TestMapTop:testCanGetRecord()

  local mapTopCacherMock = mach.mock_object(MapTopCacher, "MapTopCacherMock");
  self.mapTop:setMapTopCacher(mapTopCacherMock);

  -- Record with this rank doesn't exist
  mapTopCacherMock.getRecordByRank
                  :should_be_called_with(5)
                  :and_will_return(nil)
                  :when(
                    function()
                      local record = self.mapTop:getRecord(5);
                      luaunit.assertEquals(record, nil);
                    end
                  );

  -- Record with this rank exists
  local existingRecord = MapRecord:__construct(
    Player:__construct("a_pro", "10.0.0.3"), 13421, GUN_KNIFE, TEAM_RVSF, self.mapTop, 5
  );

  mapTopCacherMock.getRecordByRank
                  :should_be_called_with(5)
                  :and_will_return(existingRecord)
                  :when(
                    function ()
                      local record = self.mapTop:getRecord(5);
                      luaunit.assertEquals(record, existingRecord);
                    end
                  );

end

---
-- Checks whether the maptop can find out whether a player name is unique.
--
function TestMapTop:testCanCheckWhetherPlayerNameIsUnique()

  local names = { "gema", "hello", "experts", "pro", "gema", "experts" };
  local records = {};
  for i, name in ipairs(names) do
    records[i] = MapRecord:__construct(
      Player:__construct(name, "127.0.0.1"), i * 100, GUN_KNIFE, TEAM_CLA, self.mapTop, i
    );
  end

  local mapTopCacherMock = mach.mock_object(MapTopCacher, "MapTopCacherMock");
  self.mapTop:setMapTopCacher(mapTopCacherMock);

  mapTopCacherMock.getRecords
                  :should_be_called()
                  :multiple_times(4)
                  :and_will_return(records)
                  :when(
                    function ()
                      luaunit.assertFalse(self.mapTop:isPlayerNameUnique("gema"));
                      luaunit.assertFalse(self.mapTop:isPlayerNameUnique("experts"));
                      luaunit.assertTrue(self.mapTop:isPlayerNameUnique("hello"));
                      luaunit.assertTrue(self.mapTop:isPlayerNameUnique("pro"));
                    end
                  );

end

---
-- Checks whether the maptop can fetch the number of records as expected.
--
function TestMapTop:testCanGetNumberOfRecords()

  local mapTopCacherMock = mach.mock_object(MapTopCacher, "MapTopCacherMock");
  self.mapTop:setMapTopCacher(mapTopCacherMock);

  local testNumbersOfRecords = { 4, 1, 7, 3, 5 };

  for index, testNumberOfRecords in ipairs(testNumbersOfRecords) do

    mapTopCacherMock.getNumberOfRecords
                    :should_be_called()
                    :and_will_return(testNumberOfRecords)
                    :when(
                      function ()
                        local numberOfRecords = self.mapTop:getNumberOfRecords();
                        luaunit.assertEquals(numberOfRecords, testNumberOfRecords);
                      end
                    );

  end

end

---
-- Checks whether the maptop can load the records for a map.
--
function TestMapTop:testCanLoadRecords()

  local mapTopCacherMock = mach.mock_object(MapTopCacher, "MapTopCacherMock");
  local mapTopLoaderMock = mach.mock_object(MapTopLoader, "MapTopLoaderMock");
  self.mapTop:setMapTopCacher(mapTopCacherMock);
  self.mapTop:setMapTopLoader(mapTopLoaderMock);

  local testMapName = "pro_gema";
  local testRecords = {
    MapRecord:__construct(
      Player:__construct("newPlayer", "10.0.0.2"), 13670, GUN_KNIFE, TEAM_CLA, self.mapTop, 1
    ),
    MapRecord:__construct(
      Player:__construct("pro", "10.0.0.106"), 150321, GUN_ASSAULT, TEAM_RVSF, self.mapTop, 2
    )
  };

  self.gemaModMock.getDataBase
                  :should_be_called()
                  :and_will_return("my_db")
                  :and_then(
                    mapTopLoaderMock.fetchRecords
                                    :should_be_called_with("my_db", testMapName)
                                    :and_will_return(testRecords)
                  )
                  :and_then(
                    mapTopCacherMock.setRecords
                                    :should_be_called_with(testRecords)
                  )
                  :when(
                    function ()
                      self.mapTop:loadRecords(testMapName);
                    end
                  );

end

---
-- Checks whether the maptop can predict ranks of unsaved records.
--
function TestMapTop:testCanPredictRank()

  local mapTopCacherMock = mach.mock_object(MapTopCacher, "MapTopCacherMock");
  self.mapTop:setMapTopCacher(mapTopCacherMock);

  local testSets = {

    -- Empty maptop and new record
    {
      ["newRecordMilliseconds"] = 2,
      ["existingRecords"] = {},
      ["expectedRank"] = 1,
      ["numberOfRecords"] = 0
    },

    -- Some records in maptop and new best time
    {
      ["newRecordMilliseconds"] = 2,
      ["existingRecords"] = {
        [1] = MapRecord:__construct(
          Player:__construct("snail", "1.2.3.4"), 200000, GUN_ASSAULT, TEAM_CLA, self.mapTop, 1
        ),
        [2] = MapRecord:__construct(
          Player:__construct("slow_snail", "2.3.4.5"), 200020, GUN_SHOTGUN, TEAM_RVSF, self.mapTop, 2
        ),
        [3] = MapRecord:__construct(
          Player:__construct("fast_snail", "1.1.1.1"), 210500, GUN_KNIFE, TEAM_RVSF, self.mapTop, 3
        )
      },
      ["expectedRank"] = 1
    },

    -- Some records in maptop and time in between the records
    {
      ["newRecordMilliseconds"] = 200019,
      ["existingRecords"] = {
        [1] = MapRecord:__construct(
          Player:__construct("snail", "1.2.3.4"), 200000, GUN_ASSAULT, TEAM_CLA, self.mapTop, 1
        ),
        [2] = MapRecord:__construct(
          Player:__construct("slow_snail", "2.3.4.5"), 200020, GUN_SHOTGUN, TEAM_RVSF, self.mapTop, 2
        ),
        [3] = MapRecord:__construct(
          Player:__construct("fast_snail", "1.1.1.1"), 210500, GUN_KNIFE, TEAM_RVSF, self.mapTop, 3
        )
      },
      ["expectedRank"] = 2
    },

    -- Some records in maptop and new worst time
    {
      ["newRecordMilliseconds"] = 999999,
      ["existingRecords"] = {
        [1] = MapRecord:__construct(
          Player:__construct("snail", "1.2.3.4"), 200000, GUN_ASSAULT, TEAM_CLA, self.mapTop, 1
        ),
        [2] = MapRecord:__construct(
          Player:__construct("slow_snail", "2.3.4.5"), 200020, GUN_SHOTGUN, TEAM_RVSF, self.mapTop, 2
        ),
        [3] = MapRecord:__construct(
          Player:__construct("fast_snail", "1.1.1.1"), 210500, GUN_KNIFE, TEAM_RVSF, self.mapTop, 3
        )
      },
      ["expectedRank"] = 4,
      ["numberOfRecords"] = 3
    }
  }

  for index, testSet in ipairs(testSets) do

    local expectedMapTopCacherCall = mapTopCacherMock.getRecords
                                                     :should_be_called()
                                                     :and_will_return(testSet["existingRecords"]);

    if (testSet["numberOfRecords"] ~= nil) then
      expectedMapTopCacherCall:and_then(
        mapTopCacherMock.getNumberOfRecords
                        :should_be_called()
                        :and_will_return(testSet["numberOfRecords"])
      );
    end

    expectedMapTopCacherCall:when(
      function ()
        local predictedRank = self.mapTop:predictRank(testSet["newRecordMilliseconds"]);
        luaunit.assertEquals(predictedRank, testSet["expectedRank"]);
      end
    );

  end

end


return TestMapTop;
