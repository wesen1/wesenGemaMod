---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local luaunit = require("luaunit");
local mach = require("mach");

local GemaMod = require("GemaMod");
local EventHandler = require("EventHandler");
local FlagActionHandler = require("EventHandler/FlagActionHandler");
local MapChangeHandler = require("EventHandler/MapChangeHandler");
local PlayerCallVoteHandler = require("EventHandler/PlayerCallVoteHandler");
local PlayerConnectHandler = require("EventHandler/PlayerConnectHandler");
local PlayerDisconnectHandler = require("EventHandler/PlayerDisconnectHandler");
local PlayerNameChangeHandler = require("EventHandler/PlayerNameChangeHandler");
local PlayerRoleChangeHandler = require("EventHandler/PlayerRoleChangeHandler");
local PlayerSayTextHandler = require("EventHandler/PlayerSayTextHandler");
local PlayerSendMapHandler = require("EventHandler/PlayerSendMapHandler");
local PlayerShootHandler = require("EventHandler/PlayerShootHandler");
local PlayerSpawnHandler = require("EventHandler/PlayerSpawnHandler");
local PlayerSpawnAfterHandler = require("EventHandler/PlayerSpawnAfterHandler");
local VoteEndHandler = require("EventHandler/VoteEndHandler");

---
-- Checks whether the EventHandler wrapper class works as expected.
--
TestEventHandler = {};


---
-- Method that is called before each test is executed.
--
function TestEventHandler:setUp()
  
  self.gemaModMock = mach.mock_object(GemaMod, "GemaModMock");
  self.eventHandler = EventHandler:__construct(self.gemaModMock);

end

---
-- Method that is called after each test is finished.
--
function TestEventHandler:tearDown()
  
  self.gemaModMock = nil;
  self.eventHandler = nil;

end


---
-- Checks whether the getters/setters work as expected.
--
function TestEventHandler:testCanGetAttributes()

  local flagActionHandlerMock = mach.mock_object(FlagActionHandler, "FlagActionHandlerMock");
  local mapChangeHandlerMock = mach.mock_object(MapChangeHandler, "MapChangeHandlerMock");
  local playerCallVoteHandlerMock = mach.mock_object(PlayerCallVoteHandler, "PlayerCallVoteHandlerMock");
  local playerConnectHandlerMock = mach.mock_object(PlayerConnectHandler, "PlayerConnectHandlerMock");
  local playerDisconnectHandlerMock = mach.mock_object(PlayerDisconnectHandler, "PlayerDisconnectHandlerMock");
  local playerNameChangeHandlerMock = mach.mock_object(PlayerNameChangeHandler, "PlayerNameChangeHandlerMock");
  local playerRoleChangeHandlerMock = mach.mock_object(PlayerRoleChangeHandler, "PlayerRoleChangeHandlerMock");
  local playerSayTextHandlerMock = mach.mock_object(PlayerSayTextHandler, "PlayerSayTextHandlerMock");
  local playerSendMapHandlerMock = mach.mock_object(PlayerSendMapHandler, "PlayerSendMapHandlerMock");
  local playerShootHandlerMock = mach.mock_object(PlayerShootHandler, "PlayerShootHandlerMock");
  local playerSpawnHandlerMock = mach.mock_object(PlayerSpawnHandler, "PlayerSpawnHandlerMock");
  local playerSpawnAfterHandlerMock = mach.mock_object(PlayerSpawnAfterHandler, "PlayerSpawnAfterHandlerMock");
  local voteEndHandlerMock = mach.mock_object(VoteEndHandler, "VoteEndHandlerMock");

  -- Set the test values
  self.eventHandler:setFlagActionHandler(flagActionHandlerMock);
  self.eventHandler:setMapChangeHandler(mapChangeHandlerMock);
  self.eventHandler:setPlayerCallVoteHandler(playerCallVoteHandlerMock);
  self.eventHandler:setPlayerConnectHandler(playerConnectHandlerMock);
  self.eventHandler:setPlayerDisconnectHandler(playerDisconnectHandlerMock);
  self.eventHandler:setPlayerNameChangeHandler(playerNameChangeHandlerMock);
  self.eventHandler:setPlayerRoleChangeHandler(playerRoleChangeHandlerMock);
  self.eventHandler:setPlayerSayTextHandler(playerSayTextHandlerMock);
  self.eventHandler:setPlayerSendMapHandler(playerSendMapHandlerMock);
  self.eventHandler:setPlayerShootHandler(playerShootHandlerMock);
  self.eventHandler:setPlayerSpawnHandler(playerSpawnHandlerMock);
  self.eventHandler:setPlayerSpawnAfterHandler(playerSpawnAfterHandlerMock);
  self.eventHandler:setVoteEndHandler(voteEndHandlerMock);

  -- Get the test values
  luaunit.assertEquals(self.eventHandler:getFlagActionHandler(), flagActionHandlerMock);
  luaunit.assertEquals(self.eventHandler:getMapChangeHandler(), mapChangeHandlerMock);
  luaunit.assertEquals(self.eventHandler:getPlayerCallVoteHandler(), playerCallVoteHandlerMock);
  luaunit.assertEquals(self.eventHandler:getPlayerConnectHandler(), playerConnectHandlerMock);
  luaunit.assertEquals(self.eventHandler:getPlayerDisconnectHandler(), playerDisconnectHandlerMock);
  luaunit.assertEquals(self.eventHandler:getPlayerNameChangeHandler(), playerNameChangeHandlerMock);
  luaunit.assertEquals(self.eventHandler:getPlayerRoleChangeHandler(), playerRoleChangeHandlerMock);
  luaunit.assertEquals(self.eventHandler:getPlayerSayTextHandler(), playerSayTextHandlerMock);
  luaunit.assertEquals(self.eventHandler:getPlayerSendMapHandler(), playerSendMapHandlerMock);
  luaunit.assertEquals(self.eventHandler:getPlayerShootHandler(), playerShootHandlerMock);
  luaunit.assertEquals(self.eventHandler:getPlayerSpawnHandler(), playerSpawnHandlerMock);
  luaunit.assertEquals(self.eventHandler:getPlayerSpawnAfterHandler(), playerSpawnAfterHandlerMock);
  luaunit.assertEquals(self.eventHandler:getVoteEndHandler(), voteEndHandlerMock);

end
