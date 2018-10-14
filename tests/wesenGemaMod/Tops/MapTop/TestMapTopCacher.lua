---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local luaunit = require("luaunit");
local mach = require("mach");

local MapTop = require("Tops/MapTop/MapTop");
local MapTopCacher = require("Tops/MapTop/MapTopCacher");
local MapRecord = require("Tops/MapTop/MapRecord/MapRecord");
local Player = require("Player/Player");
local TableUtils = require("Util/TableUtils");

---
-- Checks whether the MapTopCacher class works as expected.
--
-- @type TestMapTopCacher
--
TestMapTopCacher = {};


---
-- Method that is called before each test is executed.
--
function TestMapTopCacher:setUp()

  self.mapTopMock = mach.mock_object(MapTop, "MapTopMock");
  self.mapTopCacher = MapTopCacher:__construct(self.mapTopMock);

end

---
-- Method that is called after each test is finished.
--
function TestMapTopCacher:tearDown()

  self.mapTopMock = nil;
  self.mapTopCacher = nil;

end


---
-- Checks whether the getters/setters work as expected.
--
function TestMapTopCacher:testCanGetAttributes()

  local mapTopMock = mach.mock_object(MapTop, "TestMapTopMock");
  local records = { 1, 2, 3, 4 };

  self.mapTopCacher:setParentMapTop(mapTopMock);
  self.mapTopCacher:setRecords(records);

  luaunit.assertEquals(self.mapTopCacher:getParentMapTop(), mapTopMock);
  luaunit.assertEquals(self.mapTopCacher:getRecords(), records);

end

---
-- Checks whether a record can be added as expected.
--
function TestMapTopCacher:testCanAddRecord()

  local newRecord = MapRecord:__construct(
    Player:__construct("gema_expert", "192.192.192.192"), 123456, GUN_SHOTGUN, TEAM_CLA, self.mapTopMock, 1
  );

  -- First record of a player name in empty maptop
  newRecord:setRank(1);
  self:canAddRecord(newRecord, 0, nil, {}, 1, 1);

  -- First record of a player name, rank 1 in filled maptop
  newRecord:setRank(1);
  self:canAddRecord(newRecord, 5, nil, {}, 6, 1);

  -- First record of a player name, middle rank in filled maptop
  newRecord:setRank(3);
  self:canAddRecord(newRecord, 5, nil, {}, 6, 3);

  -- First record of a player name, last rank in filled maptop
  newRecord:setRank(6);
  self:canAddRecord(newRecord, 5, nil, {}, 6, 6);


  -- Updated record of a player name, rank 1 in maptop with 1 record
  newRecord:setRank(1);
  self:canAddRecord(newRecord, 1, 1, {}, 1, 1);

  -- Updated record of a player name, rank 1 in maptop with multiple records
  newRecord:setRank(1);
  self:canAddRecord(newRecord, 5, 1, {}, 5, 1);

  -- Updated record of a player name, middle rank in maptop
  newRecord:setRank(3);
  self:canAddRecord(newRecord, 5, 3, {}, 5, 3);

  -- Updated record of a player name, last rank in maptop
  newRecord:setRank(5);
  self:canAddRecord(newRecord, 5, 5, {}, 5, 5);

end

---
-- Checks whether one record can be added to the cached maptop as expected.
--
-- @tparam MapRecord _newRecord The new record that will be added to the cached maptop
-- @tparam int _numberOfExistingRecords The number of existing records in the cached maptop
-- @tparam int _existingRank The existing rank of the player name
-- @tparam int[] _ranksWithNewRecordName The ranks that have the same name as the new record
-- @tparam int _expectedNumberOfRecords The expected number of records after adding the new record
-- @tparam int _expectedRank The expected rank of the new record
--
function TestMapTopCacher:canAddRecord(_newRecord, _numberOfExistingRecords, _existingRank, _ranksWithNewRecordName, _expectedNumberOfRecords, _expectedRank)

  local testRecords = {};
  for i = 1, _numberOfExistingRecords, 1 do
    testRecords[i] = TableUtils:copy(_newRecord);
    testRecords[i]:setRank(i);

    if (not TableUtils:inTable(i, _ranksWithNewRecordName) and i ~= _existingRank) then
      testRecords[i]:getPlayer():setName("noob");
    end

  end

  self.mapTopCacher:setRecords(testRecords);
  luaunit.assertEquals(self.mapTopCacher:getNumberOfRecords(), _numberOfExistingRecords);

  self.mapTopCacher:addRecord(_newRecord, _existingRank);
  luaunit.assertEquals(self.mapTopCacher:getNumberOfRecords(), _expectedNumberOfRecords);
  luaunit.assertEquals(self.mapTopCacher:getRecords()[_expectedRank], _newRecord);

end

---
-- Checks whether records can be fetched by ranks.
--
function TestMapTopCacher:testCanGetRecordByRank()

  local records = { "one", "two", "two plus one", "four", "six minus 1" };
  self.mapTopCacher:setRecords(records);

  luaunit.assertEquals(self.mapTopCacher:getRecordByRank(1), "one");
  luaunit.assertEquals(self.mapTopCacher:getRecordByRank(2), "two");
  luaunit.assertEquals(self.mapTopCacher:getRecordByRank(4), "four");
  luaunit.assertEquals(self.mapTopCacher:getRecordByRank(3), "two plus one");
  luaunit.assertEquals(self.mapTopCacher:getRecordByRank(5), "six minus 1");
  luaunit.assertEquals(self.mapTopCacher:getRecordByRank(6), nil);
  luaunit.assertEquals(self.mapTopCacher:getRecordByRank(7), nil);

end

---
-- Checks whether records can be fetched by players.
--
function TestMapTopCacher:testCanGetRecordByPlayer()

  local testPlayerA = Player:__construct("a_pro_is_pro", "1.2.3.4");
  local testPlayerB = Player:__construct("he_is_not_pro", "4.3.2.1");
  local testPlayerC = Player:__construct("noob_with_no_rank", "100.100.200.200");
  local testMapRecordA = MapRecord:__construct(testPlayerA, 12345, GUN_CARBINE, TEAM_RVSF, self.mapTopMock, 6);
  local testMapRecordB = MapRecord:__construct(testPlayerB, 12345, GUN_CARBINE, TEAM_RVSF, self.mapTopMock, 1);
  local records = {};

  for i = 1, 5, 1 do
    records[i] = testMapRecordB;
    records[i]:setPlayer(testPlayerB);
    records[i]:setRank(i);
  end

  records[6] = testMapRecordA;

  self.mapTopCacher:setRecords(records);
  
  luaunit.assertEquals(self.mapTopCacher:getRecordByPlayer(testPlayerA), testMapRecordA);
  luaunit.assertNil(self.mapTopCacher:getRecordByPlayer(testPlayerC));

end


---
-- Checks whether the counting of the map records works as expected.
--
function TestMapTopCacher:testCanGetNumberOfRecords()

  local testValues = {
    { ["records"] = { 1 }, ["expectedNumberOfRecords"] = 1 },
    { ["records"] = { 1, 2, 3 }, ["expectedNumberOfRecords"] = 3 },
    { ["records"] = { 1, 2 }, ["expectedNumberOfRecords"] = 2 },
    { ["records"] = { 2 }, ["expectedNumberOfRecords"] = 1 },
    { ["records"] = { 5, 6, 8 }, ["expectedNumberOfRecords"] = 3 },
  };

  for index, testValueSet in ipairs(testValues) do

    self.mapTopCacher:setRecords(testValueSet["records"]);
    luaunit.assertEquals(self.mapTopCacher:getNumberOfRecords(), testValueSet["expectedNumberOfRecords"]);

  end

end
