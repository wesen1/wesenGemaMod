---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local FlagActionHandler = require("EventHandler/FlagActionHandler");
local MapChangeHandler = require("EventHandler/MapChangeHandler");
local PlayerCallVoteHandler = require("EventHandler/PlayerCallVoteHandler");
local PlayerConnectHandler = require("EventHandler/PlayerConnectHandler");
local PlayerDisconnectAfterHandler = require("EventHandler/PlayerDisconnectAfterHandler");
local PlayerNameChangeHandler = require("EventHandler/PlayerNameChangeHandler");
local PlayerRoleChangeHandler = require("EventHandler/PlayerRoleChangeHandler");
local PlayerSayTextHandler = require("EventHandler/PlayerSayTextHandler");
local PlayerSendMapHandler = require("EventHandler/PlayerSendMapHandler");
local PlayerShootHandler = require("EventHandler/PlayerShootHandler");
local PlayerSpawnHandler = require("EventHandler/PlayerSpawnHandler");
local PlayerSpawnAfterHandler = require("EventHandler/PlayerSpawnAfterHandler");
local VoteEndHandler = require("EventHandler/VoteEndHandler");

---
-- Wrapper class for the event handlers.
--
-- @type EventHandler
--
local EventHandler = setmetatable({}, {});


---
-- The flag action event handler
--
-- @tfield FlagActionHandler flagActionHandler
--
EventHandler.flagActionHandler = nil;

---
-- The map change event handler
--
-- @tfield MapChangeHandler mapChangeHandler
--
EventHandler.mapChangeHandler = nil;

---
-- The player call vote event handler
--
-- @tfield PlayerCallVoteHandler playerCallVoteHandler
--
EventHandler.playerCallVoteHandler = nil;

---
-- The player connect event handler
--
-- @tfield PlayerConnectHandler playerConnectHandler
--
EventHandler.playerConnectHandler = nil;

---
-- The player disconnect event after handler
--
-- @tfield PlayerDisconnectAfterHandler playerDisconnectHandler
--
EventHandler.playerDisconnectAfterHandler = nil;

---
-- The player name change event handler
--
-- @tfield PlayerNameChangeHandler playerNameChangeHandler
--
EventHandler.playerNameChangeHandler = nil;

---
-- The player role change event handler
--
-- @tfield PlayerRoleChangeHandler playerRoleChangeHandler
--
EventHandler.playerRoleChangeHandler = nil;

---
-- The player say text event handler
--
-- @tfield PlayerSayTextHandler playerSayTextHandler
--
EventHandler.playerSayTextHandler = nil;

---
-- The player send map event handler
--
-- @tfield PlayerSendMapHandler playerSendMapHandler
--
EventHandler.playerSendMapHandler = nil;

---
-- The player shoot handler
--
-- @tfield PlayerShootHandler playerShootHandler
--
EventHandler.playerShootHandler = nil;

---
-- The player spawn event handler
--
-- @tfield PlayerSpawnHandler playerSpawnHandler
--
EventHandler.playerSpawnHandler = nil;

---
-- The player spawn after event handler
--
-- @tfield PlaySpawnAfterHandler playerSpawnAfterHandler
--
EventHandler.playerSpawnAfterHandler = nil;

---
-- The vote end handler
--
-- @tfield VoteEndHandler voteEndHandler
--
EventHandler.voteEndHandler = nil;


---
-- EventHandler constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn EventHandler The EventHandler instance
--
function EventHandler:__construct(_parentGemaMod)

  local instance = setmetatable({}, {__index = EventHandler});

  instance.flagActionHandler = FlagActionHandler(_parentGemaMod);
  instance.mapChangeHandler = MapChangeHandler(_parentGemaMod);
  instance.playerCallVoteHandler = PlayerCallVoteHandler(_parentGemaMod);
  instance.playerConnectHandler = PlayerConnectHandler(_parentGemaMod);
  instance.playerDisconnectAfterHandler = PlayerDisconnectAfterHandler(_parentGemaMod);
  instance.playerNameChangeHandler = PlayerNameChangeHandler(_parentGemaMod);
  instance.playerRoleChangeHandler = PlayerRoleChangeHandler(_parentGemaMod);
  instance.playerSayTextHandler = PlayerSayTextHandler(_parentGemaMod);
  instance.playerSendMapHandler = PlayerSendMapHandler(_parentGemaMod);
  instance.playerShootHandler = PlayerShootHandler(_parentGemaMod);
  instance.playerSpawnHandler = PlayerSpawnHandler(_parentGemaMod);
  instance.playerSpawnAfterHandler = PlayerSpawnAfterHandler(_parentGemaMod);
  instance.voteEndHandler = VoteEndHandler(_parentGemaMod);

  return instance;

end

getmetatable(EventHandler).__call = EventHandler.__construct;


-- Getters and setters

---
-- Returns the flag action handler.
--
-- @treturn FlagActionHandler The flag action handler
--
function EventHandler:getFlagActionHandler()
  return self.flagActionHandler;
end

---
-- Returns the map change handler.
--
-- @treturn MapChangeHandler The map change handler
--
function EventHandler:getMapChangeHandler()
  return self.mapChangeHandler;
end

---
-- Returns the player call vote handler.
--
-- @treturn PlayerCallVoteHandler The player call vote handler
--
function EventHandler:getPlayerCallVoteHandler()
  return self.playerCallVoteHandler;
end

---
-- Returns the player connect handler.
--
-- @treturn PlayerConnectHandler The player connect handler
--
function EventHandler:getPlayerConnectHandler()
  return self.playerConnectHandler;
end

---
-- Returns the player disconnect after handler.
--
-- @treturn PlayerDisconnectAfterHandler The player disconnect after handler
--
function EventHandler:getPlayerDisconnectAfterHandler()
  return self.playerDisconnectAfterHandler;
end

---
-- Returns the player name change handler.
--
-- @treturn PlayerNameChangeHandler The player name change handler
--
function EventHandler:getPlayerNameChangeHandler()
  return self.playerNameChangeHandler;
end

---
-- Returns the player role change handler.
--
-- @treturn PlayerRoleChangeHandler The player role change handler
--
function EventHandler:getPlayerRoleChangeHandler()
  return self.playerRoleChangeHandler;
end

---
-- Returns the player say text handler.
--
-- @treturn PlayerSayTextHandler The player say text handler
--
function EventHandler:getPlayerSayTextHandler()
  return self.playerSayTextHandler;
end

---
-- Returns the player send map handler.
--
-- @treturn PlayerSendMapHandler The player send map handler
--
function EventHandler:getPlayerSendMapHandler()
  return self.playerSendMapHandler;
end

---
-- Returns the player shoot handler.
--
-- @treturn PlayerShootHandler The player shoot handler
--
function EventHandler:getPlayerShootHandler()
  return self.playerShootHandler;
end

---
-- Returns the player spawn handler.
--
-- @treturn PlayerSpawnHandler The player spawn handler
--
function EventHandler:getPlayerSpawnHandler()
  return self.playerSpawnHandler;
end

---
-- Returns the player spawn after handler.
--
-- @treturn PlayerSpawnAfterHandler The player spawn after handler
--
function EventHandler:getPlayerSpawnAfterHandler()
  return self.playerSpawnAfterHandler;
end

---
-- Returns the vote end handler.
--
-- @treturn VoteEndHandler The vote end handler
--
function EventHandler:getVoteEndHandler()
  return self.voteEndHandler;
end


return EventHandler;
