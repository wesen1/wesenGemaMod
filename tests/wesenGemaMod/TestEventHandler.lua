---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

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
local TestCase = require("TestFrameWork/TestCase");
local VoteEndHandler = require("EventHandler/VoteEndHandler");

---
-- Checks whether the EventHandler wrapper class works as expected.
--
-- @type TestEventHandler
--
local TestEventHandler = setmetatable({}, {__index = TestCase});


---
-- Checks whether the constructor works as expected.
--
function TestEventHandler:testCanBeConstructed()

  local gemaModeMock = self:getMock(GemaMode, "GemaModeMock");
  local eventHandler;

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

  self.assertInstanceOf(eventHandler, EventHandler);

  -- Check whether the event handlers are instances of the EventHandler classes
  self.assertInstanceOf(eventHandler:getFlagActionHandler(), FlagActionHandler);
  self.assertInstanceOf(eventHandler:getMapChangeHandler(), MapChangeHandler);
  self.assertInstanceOf(eventHandler:getPlayerCallVoteHandler(), PlayerCallVoteHandler);
  self.assertInstanceOf(eventHandler:getPlayerConnectHandler(), PlayerConnectHandler);
  self.assertInstanceOf(eventHandler:getPlayerDisconnectHandler(), PlayerDisconnectHandler);
  self.assertInstanceOf(eventHandler:getPlayerDisconnectAfterHandler(), PlayerDisconnectAfterHandler);
  self.assertInstanceOf(eventHandler:getPlayerNameChangeHandler(), PlayerNameChangeHandler);
  self.assertInstanceOf(eventHandler:getPlayerRoleChangeHandler(), PlayerRoleChangeHandler);
  self.assertInstanceOf(eventHandler:getPlayerSayTextHandler(), PlayerSayTextHandler);
  self.assertInstanceOf(eventHandler:getPlayerSendMapHandler(), PlayerSendMapHandler);
  self.assertInstanceOf(eventHandler:getPlayerShootHandler(), PlayerShootHandler);
  self.assertInstanceOf(eventHandler:getPlayerSpawnHandler(), PlayerSpawnHandler);
  self.assertInstanceOf(eventHandler:getVoteEndHandler(), VoteEndHandler);

end


return TestEventHandler;
