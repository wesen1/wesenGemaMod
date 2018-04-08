---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--
local luaunit = require("luaunit");
local mach = require("mach");

local DataBase = "";
local Output = "";
local PlayerInformationLoader = "";
local PlayerInformationSaver = "";


---
-- Checks whether the Player class works as expected.
--
-- @type TestPlayer
--
TestPlayer = {};


---
-- Replaces the loaded dependencies of the test by the real dependencies.
-- This function must be called before starting each test.
--
function TestPlayer:resetDependencies()

  package.loaded["DataBase"] = nil;
  package.loaded["Outputs/Output"] = nil;
  package.loaded["Player/PlayerInformationLoader"] = nil;
  package.loaded["Player/PlayerInformationSaver"] = nil;

  DataBase = require("DataBase");
  Output = require("Outputs/Output");
  PlayerInformationLoader = require("Player/PlayerInformationLoader");
  PlayerInformationSaver = require("Player/PlayerInformationSaver");

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

  self:resetDependencies();

  local Player = "";
  local outputMockTextColor = "\f0";

  -- Unload Player module
  package.loaded["Player/Player"] = nil;

  -- Overwrite Output dependency with mock
  local outputMock = mach.mock_object(Output, "OutputMock");
  package.loaded["Outputs/Output"] = outputMock;

  outputMock.getColor:should_be_called_with("playerTextDefault")
                     :and_will_return(outputMockTextColor)
                     :when(
                       function()
                         Player = require("Player/Player");
                       end
                     );

  local testPlayer = Player:__construct("test", "1.1.1.1");

  -- Check default values
  luaunit.assertEquals(testPlayer:getId(), -1);
  luaunit.assertEquals(testPlayer:getName(), "test");
  luaunit.assertEquals(testPlayer:getIp(), "1.1.1.1");
  luaunit.assertEquals(testPlayer:getLevel(), 0);
  luaunit.assertEquals(testPlayer:getStartTime(), 0);
  luaunit.assertEquals(testPlayer:getTeam(), -1);
  luaunit.assertEquals(testPlayer:getTextColor(), outputMockTextColor);
  luaunit.assertEquals(testPlayer:getWeapon(), -1);

  -- Set test values
  testPlayer:setId(_id);
  testPlayer:setName(_name);
  testPlayer:setIp(_ip);
  testPlayer:setLevel(_level);
  testPlayer:setStartTime(_startTime);
  testPlayer:setTeam(_team);
  testPlayer:setTextColor(_textColor);
  testPlayer:setWeapon(_weapon);

  -- CHeck whether test values were set
  luaunit.assertEquals(testPlayer:getId(), _id);
  luaunit.assertEquals(testPlayer:getName(), _name);
  luaunit.assertEquals(testPlayer:getIp(), _ip);
  luaunit.assertEquals(testPlayer:getLevel(), _level);
  luaunit.assertEquals(testPlayer:getStartTime(), _startTime);
  luaunit.assertEquals(testPlayer:getTeam(), _team);
  luaunit.assertEquals(testPlayer:getTextColor(), _textColor);
  luaunit.assertEquals(testPlayer:getWeapon(), _weapon);

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

  self:resetDependencies();

  -- Overwrite PlayerInformationLoader dependency with mock
  local PlayerInformationLoaderMock = mach.mock_object(PlayerInformationLoader, "PlayerInformationLoaderMock");
  package.loaded["Player/PlayerInformationLoader"] = PlayerInformationLoaderMock;

  -- Overwrite PlayerInformationSaver dependency with mock
  local PlayerInformationSaverMock = mach.mock_object(PlayerInformationSaver, "PlayerInformationSaverMock");
  package.loaded["Player/PlayerInformationSaver"] = PlayerInformationSaverMock;


  -- Unload player module
  package.loaded["Player/Player"] = nil

  local Player = "";
  local outputMockTextColor = "\f0";

  -- Overwrite Output dependency with mock
  local outputMock = mach.mock_object(Output, "OutputMock");
  package.loaded["Outputs/Output"] = outputMock;

  outputMock.getColor:should_be_called_with("playerTextDefault")
                     :and_will_return(outputMockTextColor)
                     :when(
                       function()
                         Player = require("Player/Player");
                       end
                     );


  local testPlayer = Player:__construct(_playerName, _playerIp);
  local dataBaseMock = mach.mock_object(DataBase, "DataBaseMock");

  PlayerInformationSaverMock.savePlayer:should_be_called_with(dataBaseMock, testPlayer)
                                       :and_will_return(nil)
                                       :and_then(
                                         PlayerInformationLoaderMock.fetchPlayerId:should_be_called_with(
                                                                                    dataBaseMock,
                                                                                    testPlayer
                                                                                  )
                                                                                  :and_will_return(
                                                                                    _playerId
                                                                                  )
                                       )
                                       :when(
                                         function()
                                           testPlayer:savePlayer(dataBaseMock)
                                         end
                                       );

  luaunit.assertEquals(testPlayer:getId(), _playerId);

end
