---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local luaunit = require("luaunit-custom");
local mach = require("mach");

local GemaMode = require("GemaMode");
local EventHandler = require("EventHandler");
local FlagActionHandler = require("EventHandler/FlagActionHandler");
local MapChangeHandler = require("EventHandler/MapChangeHandler");
local PlayerCallVoteHandler = require("EventHandler/PlayerCallVoteHandler");
local PlayerConnectHandler = require("EventHandler/PlayerConnectHandler");
local PlayerDisconnectHandler = require("EventHandler/PlayerDisconnectHandler");
local PlayerDisconnectAfterHandler = require("EventHandler/PlayerDisconnectAfterHandler");
local PlayerNameChangeHandler = require("EventHandler/PlayerNameChangeHandler");
local PlayerRoleChangeHandler = require("EventHandler/PlayerRoleChangeHandler");
local PlayerSayTextHandler = require("EventHandler/PlayerSayTextHandler");
local PlayerSendMapHandler = require("EventHandler/PlayerSendMapHandler");
local PlayerShootHandler = require("EventHandler/PlayerShootHandler");
local PlayerSpawnHandler = require("EventHandler/PlayerSpawnHandler");
local VoteEndHandler = require("EventHandler/VoteEndHandler");

---
-- Checks whether the EventHandler wrapper class works as expected.
--
-- @type TestEventHandler
--
local TestEventHandler = {};


---
-- Checks whether the constructor works as expected.
--
function TestEventHandler:testCanBeConstructed()

  local gemaModeMock = mach.mock_object(GemaMode, "GemaModeMock");
  local eventHandler = nil;

  -- Each event handler will fetch the output
  -- "PlayerCallVoteHandler" has a sub event handler "PlayerCallMapVoteHandler", therefore
  -- there is 1 more call then there are classes inside the event handler
  gemaModeMock.getOutput:should_be_called()
                        :multiple_times(14)
                        :when(
                          function()
                            eventHandler = EventHandler(gemaModeMock);
                          end
                        );

  luaunit.assertInstanceOf(eventHandler, EventHandler);

  -- Check whether the event handlers are instances of the EventHandler classes
  luaunit.assertInstanceOf(eventHandler:getFlagActionHandler(), FlagActionHandler);
  luaunit.assertInstanceOf(eventHandler:getMapChangeHandler(), MapChangeHandler);
  luaunit.assertInstanceOf(eventHandler:getPlayerCallVoteHandler(), PlayerCallVoteHandler);
  luaunit.assertInstanceOf(eventHandler:getPlayerConnectHandler(), PlayerConnectHandler);
  luaunit.assertInstanceOf(eventHandler:getPlayerDisconnectHandler(), PlayerDisconnectHandler);
  luaunit.assertInstanceOf(eventHandler:getPlayerDisconnectAfterHandler(), PlayerDisconnectAfterHandler);
  luaunit.assertInstanceOf(eventHandler:getPlayerNameChangeHandler(), PlayerNameChangeHandler);
  luaunit.assertInstanceOf(eventHandler:getPlayerRoleChangeHandler(), PlayerRoleChangeHandler);
  luaunit.assertInstanceOf(eventHandler:getPlayerSayTextHandler(), PlayerSayTextHandler);
  luaunit.assertInstanceOf(eventHandler:getPlayerSendMapHandler(), PlayerSendMapHandler);
  luaunit.assertInstanceOf(eventHandler:getPlayerShootHandler(), PlayerShootHandler);
  luaunit.assertInstanceOf(eventHandler:getPlayerSpawnHandler(), PlayerSpawnHandler);
  luaunit.assertInstanceOf(eventHandler:getVoteEndHandler(), VoteEndHandler);

end


return TestEventHandler;
