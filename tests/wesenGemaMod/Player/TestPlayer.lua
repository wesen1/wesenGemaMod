---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local DataBase = require("DataBase");
local Player = require("Player/Player");
local PlayerInformationLoader = require("Player/PlayerInformationLoader");
local PlayerInformationSaver = require("Player/PlayerInformationSaver");
local TestCase = require("TestFrameWork/TestCase");

---
-- Checks whether the Player class works as expected.
--
-- @type TestPlayer
--
local TestPlayer = setmetatable({}, {__index = TestCase});


function TestPlayer:setUp()
  TestCase.setUp(self);

  self.testPlayer = Player("a", "1.2.3.4");

end

---
-- Checks whether the getters/setters work as expected.
--
function TestPlayer:testCanGetAttributes()

  local testValues = {
    { 1, "abc", "127.0.0.1", 500, 3, 7, "\f1", 15 },
    { 2, "xyz", "192.168.0.2", 6087, 1, 3, "\f2", 16 },
    { 3, "gema", "143.23.45.12", 45678, 13, 789, "\f3", 17 },
    { 4, "pro", "172.16.23.0", 12, 11, 10, "\f4", 18 },
    { 5, "expert", "176.43.21.04", 234, 567, 8910, "\f12", 19 }
  };

  for index, testValueSet in ipairs(testValues) do
    self:canGetAttributes(unpack(testValueSet));
  end

end

---
-- Checks one of the data sets of testCanGetAttributes.
--
-- @tparam int _id The player id
-- @tparam string _name The player name
-- @tparam string _ip The player ip
-- @tparam int _level The player level
-- @tparam int _startTime The players start time
-- @tparam int _team The players team
-- @tparam string _textColor The players text color
-- @tparam int _weapon The players weapon
--
function TestPlayer:canGetAttributes(_id, _name, _ip, _level, _startTime, _team, _textColor, _weapon)

  local testPlayer = Player(0, "test", "1.1.1.1");

  -- Check default values
  self.assertEquals(testPlayer:getId(), -1);
  self.assertEquals(testPlayer:getName(), "test");
  self.assertEquals(testPlayer:getIp(), "1.1.1.1");
  self.assertEquals(testPlayer:getLevel(), 0);

  -- Set test values
  testPlayer:setId(_id);
  testPlayer:setName(_name);
  testPlayer:setIp(_ip);
  testPlayer:setLevel(_level);

  -- Check whether test values were set
  self.assertEquals(testPlayer:getId(), _id);
  self.assertEquals(testPlayer:getName(), _name);
  self.assertEquals(testPlayer:getIp(), _ip);
  self.assertEquals(testPlayer:getLevel(), _level);

end

---
-- Checks whether the equals method works as expected.
--
function TestPlayer:testCanCheckWhetherPlayersAreEqual()

  local playerA = Player:__construct("player_expert", "123.12.2.4");
  local playerB = Player:__construct("player_expert", "123.12.2.4");

  -- Check that the objects are not the same table
  self.assertNotEquals(tostring(playerA), tostring(playerB));

  -- Name and ip match
  self.assertTrue(playerA:equals(playerB));

  -- Name matches, ip does not match
  playerB:setIp("1.1.1.1");
  self.assertFalse(playerA:equals(playerB));

  -- Ip matches, name does not match
  playerB:setIp("123.12.2.4");
  playerB:setName("player_pro");
  self.assertFalse(playerA:equals(playerB));

  -- Ip and name do not match
  playerB:setIp("1.1.1.1");
  playerB:setName("pro");
  self.assertFalse(playerA:equals(playerB));

end

---
-- Checks whether the getIpString() method works as expected.
--
function TestPlayer:testCanGetIpString()

  local testPlayer = Player(0, "hello", "1.1.1.1");
  local testValueSets = {
    { ["ip"] = "1.1.1.1", ["expectedIpString"] = "1.1.1.x" },
    { ["ip"] = "127.0.0.1", ["expectedIpString"] = "127.0.0.x" },
    { ["ip"] = "10.4.2.27", ["expectedIpString"] = "10.4.2.x" },
    { ["ip"] = "192.168.49.32", ["expectedIpString"] = "192.168.49.x" },
    { ["ip"] = "172.20.145.190", ["expectedIpString"] = "172.20.145.x" },
    { ["ip"] = "127.127.34.243", ["expectedIpString"] = "127.127.34.x" }
  }

  for index, testValueSet in ipairs(testValueSets) do
    testPlayer.ip = testValueSet["ip"];
    self.assertEquals(testPlayer:getIpString(), testValueSet["expectedIpString"]);
  end

end

---
-- Checks whether the savePlayer() method works as expected.
--
function TestPlayer:testCanSavePlayer()

  local testValues = {
    { "newPlayer", "127.0.0.1", 16 },
    { "goodPlayer", "176.123.23.2", 3 },
    { "excellentPlayer", "185.244.208.9", 87 },
    { "badPlayer", "123.234.235.236", 193 },
    { "theBestPlayer", "122.122.122.122", 122 }
  };

  for index, testValueSet in ipairs(testValues) do
    self:canSavePlayer(unpack(testValueSet));
  end

end

---
-- Checks one of the data sets of testCanSavePlayer().
--
-- @tparam string _playerName The test player name
-- @tparam string _playerIp The test player ip
-- @tparam int _playerId The player id that will be returned by the mocks
--
function TestPlayer:canSavePlayer(_playerName, _playerIp, _playerId)

  local playerInformationLoaderMock = self:getDependencyMock(
                                        "Player/PlayerInformationLoader",
                                        "Player/Player",
                                        "PlayerInformationLoaderMock"
                                      );
  local playerInformationSaverMock = self:getDependencyMock(
                                       "Player/PlayerInformationSaver",
                                       "Player/Player",
                                       "PlayerInformationSaverMock"
                                     );

  Player = require("Player/Player");

  local testPlayer = Player(0, _playerName, _playerIp);
  local dataBaseMock = self:getMock(DataBase, "DataBaseMock");

  playerInformationSaverMock.savePlayer
                            :should_be_called_with(dataBaseMock, testPlayer)
                            :and_will_return(nil)
                            :and_then(
                              playerInformationLoaderMock.fetchPlayerId
                                                         :should_be_called_with(
                                                           dataBaseMock, testPlayer
                                                         )
                                                         :and_will_return(_playerId)
                            )
                            :when(
                              function()
                                testPlayer:savePlayer(dataBaseMock)
                              end
                            );

  self.assertEquals(testPlayer:getId(), _playerId);

end


return TestPlayer;
