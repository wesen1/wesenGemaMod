---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--
local luaunit = require("tests/luaunit-custom");
local mach = require("mach");

local DataBase = "";
local Output = "";
local PlayerInformationLoader = "";


---
-- Checks whether the PlayerInformationLoader class works as expected.
--
-- @type TestPlayerInformationLoader
--
local TestPlayerInformationLoader = {};


---
-- Replaces the loaded dependencies of the test by the real dependencies.
-- This function must be called before starting each test.
--
function TestPlayerInformationLoader:resetDependencies()

  package.loaded["DataBase"] = nil;
  package.loaded["Output/Output"] = nil;
  package.loaded["Player/PlayerInformationLoader"] = nil;

  DataBase = require("DataBase");
  Output = require("Output/Output");
  PlayerInformationLoader = require("Player/PlayerInformationLoader");

end


---
-- Checks one of the data sets of testCanFetchIpId(), testCanFetchNameId() or testCanFetchPlayerId().
--
-- @tparam table _expectedDataBaseCalls The expected database function calls in the format { { method, arguments, returnValue } }
-- @tparam string _methodName The name of the Player method that will be called in this test
-- @tparam table _additionalMethodArguments The additional arguments that will be passed to the called Player method
-- @tparam mixed _expectedReturnValue The expected return value
--
function TestPlayerInformationLoader:canReadInformationFromDataBase(_expectedDataBaseCalls, _methodName, _additionalMethodArguments, _expectedReturnValue)

  local dataBaseMock = mach.mock_object(DataBase, "DataBaseMock");

  local expectedFunctionCalls = "";
  local returnValue = -1;

  for index, functionCallData in ipairs(_expectedDataBaseCalls) do

    local expectedDataBaseCall = dataBaseMock[functionCallData["method"]]
                                             :should_be_called_with(unpack(functionCallData["arguments"]))
                                             :and_will_return(functionCallData["returnValue"]);

    if (index == 1) then
      expectedFunctionCalls = expectedDataBaseCall
    else
      expectedFunctionCalls:and_then(expectedDataBaseCall);
    end

  end

  expectedFunctionCalls:when(
                         function()
                           returnValue = PlayerInformationLoader[_methodName](
                                                                  PlayerInformationLoader,
                                                                  dataBaseMock,
                                                                  unpack(_additionalMethodArguments)
                                                                );
                         end
                       );

  luaunit.assertEquals(returnValue, _expectedReturnValue);

end

---
-- Checks whether ip ids can be fetched as expected.
--
function TestPlayerInformationLoader:testCanFetchIpId()

  self:resetDependencies();

  local testValues = {

    -- Valid results

    {
      {
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM ips WHERE ip='1.2.3.4';", true },
          ["returnValue"] = { { ["id"] = "5" } }
        }
      },
      "fetchIpId",
      { "1.2.3.4" },
      5
    },
    {
      {
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM ips WHERE ip='123.21.43.76';", true },
          ["returnValue"] = { { ["id"] = "16" } }
        }
      },
      "fetchIpId",
      { "123.21.43.76" },
      16
    },
    {
      {
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM ips WHERE ip='54.32.67.98';", true },
          ["returnValue"] = { { ["id"] = "152" } }
        }
      },
      "fetchIpId",
      { "54.32.67.98" },
      152
    },


    -- Empty results

    {
      {
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM ips WHERE ip='9.8.7.6';", true },
          ["returnValue"] = {}
        }
      },
      "fetchIpId",
      { "9.8.7.6" },
      nil
    },
    {
      {
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM ips WHERE ip='204.44.33.45';", true },
          ["returnValue"] = {}
        }
      },
      "fetchIpId",
      { "204.44.33.45" },
      nil
    },
    {
      {
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM ips WHERE ip='2.7.4.1';", true },
          ["returnValue"] = {}
        }
      },
      "fetchIpId",
      { "2.7.4.1" },
      nil
    }
  }

  for index, testValueSet in ipairs(testValues) do
    self:canReadInformationFromDataBase(unpack(testValueSet));
  end

end


---
-- Checks whether name ids can be fetched as expected.
--
function TestPlayerInformationLoader:testCanFetchNameId()

  self:resetDependencies();

  local testValues = {

    -- Valid results

    {
      {
        {
          ["method"] = "sanitize",
          ["arguments"] = { "myname" },
          ["returnValue"] = "mynameSanitized"
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM names WHERE name=BINARY 'mynameSanitized';", true },
          ["returnValue"] = { { ["id"] = "83" } }
        }
      },
      "fetchNameId",
      { "myname" },
      83
    },
    {
      {
        {
          ["method"] = "sanitize",
          ["arguments"] = { "fastPlayer" },
          ["returnValue"] = "fastPlayerSanitized"
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM names WHERE name=BINARY 'fastPlayerSanitized';", true },
          ["returnValue"] = { { ["id"] = "217" } }
        }
      },
      "fetchNameId",
      { "fastPlayer" },
      217
    },
    {
      {
        {
          ["method"] = "sanitize",
          ["arguments"] = { "rankOne" },
          ["returnValue"] = "rankOneSanitized"
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM names WHERE name=BINARY 'rankOneSanitized';", true },
          ["returnValue"] = { { ["id"] = "3" } }
        }
      },
      "fetchNameId",
      { "rankOne" },
      3
    },


    -- Empty result

    {
      {
        {
          ["method"] = "sanitize",
          ["arguments"] = { "gema" },
          ["returnValue"] = "gemaSanitized"
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM names WHERE name=BINARY 'gemaSanitized';", true },
          ["returnValue"] = {}
        }
      },
      "fetchNameId",
      { "gema" },
      nil
    },
    {
      {
        {
          ["method"] = "sanitize",
          ["arguments"] = { "luaPlayer" },
          ["returnValue"] = "luaPlayerSanitized"
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM names WHERE name=BINARY 'luaPlayerSanitized';", true },
          ["returnValue"] = {}
        }
      },
      "fetchNameId",
      { "luaPlayer" },
      nil
    },
    {
      {
        {
          ["method"] = "sanitize",
          ["arguments"] = { "testPlayer" },
          ["returnValue"] = "testPlayerSanitized"
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM names WHERE name=BINARY 'testPlayerSanitized';", true },
          ["returnValue"] = {}
        }
      },
      "fetchNameId",
      { "testPlayer" },
      nil
    }
  }

  for index, testValueSet in ipairs(testValues) do
    self:canReadInformationFromDataBase(unpack(testValueSet));
  end

end

---
-- Checks whether player ips can be fetched as expected.
--
function TestPlayerInformationLoader:testCanFetchPlayerId()

  self:resetDependencies();

  local Player = "";
  local outputMockTextColor = "\f0";

  -- Unload Player module
  package.loaded["Player/Player"] = nil;

  -- Overwrite Output dependency with mock
  local outputMock = mach.mock_object(Output, "Output");
  package.loaded["Outputs/Output"] = outputMock;

  outputMock.getColor
            :should_be_called_with("playerTextDefault")
            :and_will_return(outputMockTextColor)
            :when(
              function()
                Player = require("Player/Player");
              end
            );

  local testValues = {

    -- Valid results

    -- Valid result, nameId not set and ipId not set
    {
      {
        {
          ["method"] = "sanitize",
          ["arguments"] = { "mega" },
          ["returnValue"] = "megaSanitized"
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM names WHERE name=BINARY 'megaSanitized';", true },
          ["returnValue"] = { { ["id"] = "23" } }
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM ips WHERE ip='123.124.125.126';", true },
          ["returnValue"] = { { ["id"] = "15" } }
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM players WHERE name=23 AND ip=15;", true },
          ["returnValue"] = { { ["id"] = "100" } }
        }
      },
      "fetchPlayerId",
      { Player:__construct("mega", "123.124.125.126") },
      100
    },

    -- Valid result, nameId set and ipId not set
    {
      {
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM ips WHERE ip='75.45.125.136';", true },
          ["returnValue"] = { { ["id"] = "15" } }
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM players WHERE name=5 AND ip=15;", true },
          ["returnValue"] = { { ["id"] = "74" } }
        }
      },
      "fetchPlayerId",
      { Player:__construct("ultra", "75.45.125.136"), 5 },
      74
    },

    -- Valid result, nameId not set and ipId set
    {
      {
        {
          ["method"] = "sanitize",
          ["arguments"] = { "hyper" },
          ["returnValue"] = "hyperSanitized"
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM names WHERE name=BINARY 'hyperSanitized';", true },
          ["returnValue"] = { { ["id"] = "46" } }
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM players WHERE name=46 AND ip=137;", true },
          ["returnValue"] = { { ["id"] = "96" } }
        }
      },
      "fetchPlayerId",
      { Player:__construct("hyper", "123.124.125.126"), nil, 137 },
      96
    },

    -- Valid result, nameId set and ipId set
    {
      {
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM players WHERE name=778 AND ip=21;", true },
          ["returnValue"] = { { ["id"] = "72" } }
        }
      },
      "fetchPlayerId",
      { Player:__construct("mega", "123.124.125.126"), 778, 21 },
      72
    },


    -- Empty results

    -- Empty result, nameId not set and ipId not set
    {
      {
        {
          ["method"] = "sanitize",
          ["arguments"] = { "hello" },
          ["returnValue"] = "helloSanitized"
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM names WHERE name=BINARY 'helloSanitized';", true },
          ["returnValue"] = { { ["id"] = "789" } }
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM ips WHERE ip='140.1.12.99';", true },
          ["returnValue"] = { { ["id"] = "1093" } }
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM players WHERE name=789 AND ip=1093;", true },
          ["returnValue"] = {}
        }
      },
      "fetchPlayerId",
      { Player:__construct("hello", "140.1.12.99") },
      nil
    },

    -- Empty result, nameId set and ipId not set
    {
      {
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM ips WHERE ip='137.12.40.93';", true },
          ["returnValue"] = { { ["id"] = "14" } }
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM players WHERE name=54 AND ip=14;", true },
          ["returnValue"] = {}
        }
      },
      "fetchPlayerId",
      { Player:__construct("yourNameIs", "137.12.40.93"), 54 },
      nil
    },

    -- Empty result, nameId not set and ipId set
    {
      {
        {
          ["method"] = "sanitize",
          ["arguments"] = { "goodBye" },
          ["returnValue"] = "goodByeSanitized"
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM names WHERE name=BINARY 'goodByeSanitized';", true },
          ["returnValue"] = { { ["id"] = "436" } }
        },
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM players WHERE name=436 AND ip=47;", true },
          ["returnValue"] = {}
        }
      },
      "fetchPlayerId",
      { Player:__construct("goodBye", "140.1.12.99"), nil, 47 },
      nil
    },

    -- Empty result, nameId set and ipId set
    {
      {
        {
          ["method"] = "query",
          ["arguments"] = { "SELECT id FROM players WHERE name=58 AND ip=62;", true },
          ["returnValue"] = {}
        }
      },
      "fetchPlayerId",
      { Player:__construct("myNameIs", "130.24.67.68"), 58, 62 },
      nil
    },
  }

  for index, testValueSet in ipairs(testValues) do
    self:canReadInformationFromDataBase(unpack(testValueSet));
  end

end


return TestPlayerInformationLoader;
