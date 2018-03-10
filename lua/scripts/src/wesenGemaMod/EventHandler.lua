---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local FlagActionHandler = require("EventHandler/flagActionHandler");
local MapChangeHandler = require("EventHandler/mapChangeHandler");
local PlayerCallVoteHandler = require("EventHandler/playerCallVoteHandler");
local PlayerConnectHandler = require("EventHandler/playerConnectHandler");
local PlayerDisconnectHandler = require("EventHandler/playerDisconnectHandler");
local PlayerNameChangeHandler = require("EventHandler/playerNameChangeHandler");
local PlayerRoleChangeHandler = require("EventHandler/playerRoleChangeHandler");
local PlayerSayTextHandler = require("EventHandler/playerSayTextHandler");
local PlayerSendMapHandler = require("EventHandler/playerSendMapHandler");
local PlayerSpawnHandler = require("EventHandler/playerSpawnHandler");

---
-- @type EventHandler Wrapper class for the event handlers.
--
local EventHandler = {};


---
-- The flag action event handler
--
-- @tfield FlagActionHandler flagActionHandler
--
EventHandler.flagActionHandler = "";

---
-- The map change event handler
--
-- @tfield MapChangeHandler mapChangeHandler
--
EventHandler.mapChangeHandler = "";

---
-- The player call vote event handler
--
-- @tfield PlayerCallVoteHandler playerCallVoteHandler
--
EventHandler.playerCallVoteHandler = "";

---
-- The player connect event handler
--
-- @tfield PlayerConnectHandler playerConnectHandler
--
EventHandler.playerConnectHandler = "";

---
-- The player disconnect event handler
--
-- @tfield PlayerDisconnectHandler playerDisconnectHandler
--
EventHandler.playerDisconnectHandler = "";

---
-- The player name change event handler
--
-- @tfield PlayerNameChangeHandler playerNameChangeHandler
--
EventHandler.playerNameChangeHandler = "";

---
-- The player role change event handler
--
-- @tfield PlayerRoleChangeHandler playerRoleChangeHandler
--
EventHandler.playerRoleChangeHandler = "";

---
-- The player say text event handler
--
-- @tfield PlayerSayTextHandler playerSayTextHandler
--
EventHandler.playerSayTextHandler = "";

---
-- The player send map event handler
--
-- @tfield PlayerSendMapHandler playerSendMapHandler
--
EventHandler.playerSendMapHandler = "";

---
-- The player spawn event handler
--
-- @tfield PlayerSpawnHandler playerSpawnHandler
--
EventHandler.playerSpawnHandler = "";


---
-- EventHandler constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn EventHandler The EventHandler instance
--
function EventHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = EventHandler});

  instance.flagActionHandler = FlagActionHandler:__construct(_parentGemaMod);
  instance.mapChangeHandler = MapChangeHandler:__construct(_parentGemaMod);
  instance.playerCallVoteHandler = PlayerCallVoteHandler:__construct(_parentGemaMod);
  instance.playerConnectHandler = PlayerConnectHandler:__construct(_parentGemaMod);
  instance.playerDisconnectHandler = PlayerDisconnectHandler:__construct(_parentGemaMod);
  instance.playerNameChangeHandler = PlayerNameChangeHandler:__construct(_parentGemaMod);
  instance.playerRoleChangeHandler = PlayerRoleChangeHandler:__construct(_parentGemaMod);
  instance.playerSayTextHandler = PlayerSayTextHandler:__construct(_parentGemaMod);
  instance.playerSendMapHandler = PlayerSendMapHandler:__construct(_parentGemaMod);
  instance.playerSpawnHandler = PlayerSpawnHandler:__construct(_parentGemaMod);

  return instance;

end


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
-- Sets the flag action handler.
--
-- @tparam FlagActionHandler _flagActionHandler The flag action handler
--
function EventHandler:setFlagActionHandler(_flagActionHandler)
  self.flagActionHandler = _flagActionHandler;
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
-- Sets the map change handler.
--
-- @tparam MapChangeHandler _mapChangeHandler The map change handler
--
function EventHandler:setMapChangeHandler(_mapChangeHandler)
  self.mapChangeHandler = _mapChangeHandler;
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
-- Sets the player call vote handler.
--
-- @tparam PlayerCallVoteHandler _playerCallVoteHandler The player call vote handler
--
function EventHandler:setPlayerCallVoteHandler(_playerCallVoteHandler)
  self.playerCallVoteHandler = _playerCallVoteHandler;
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
-- Sets the player connect handler.
--
-- @tparam PlayerConnectHandler _playerConnectHandler The player connect handler
--
function EventHandler:setPlayerConnectHandler(_playerConnectHandler)
  self.playerConnectHandler = _playerConnectHandler;
end

---
-- Returns the player disconnect handler.
--
-- @treturn PlayerDisconnectHandler The player disconnect handler
--
function EventHandler:getPlayerDisconnectHandler()
  return self.playerDisconnectHandler;
end

---
-- Sets the player disconnect handler.
--
-- @tparam PlayerDisconnectHandler _playerDisconnectHandler The player disconnect handler
--
function EventHandler:setPlayerDisconnectHandler(_playerDisconnectHandler)
  self.playerDisconnectHandler = _playerDisconnectHandler;
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
-- Sets the player name change handler.
--
-- @tparam PlayerNameChangeHandler _playerNameChangeHandler The player name change handler
--
function EventHandler:setPlayerNameChangeHandler(_playerNameChangeHandler)
  self.playerNameChangeHandler = _playerNameChangeHandler;
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
-- Sets the player role change handler.
--
-- @tparam PlayerRoleChangeHandler _playerRoleChangeHandler The player role change handler
--
function EventHandler:setPlayerRoleChangeHandler(_playerRoleChangeHandler)
  self.playerRoleChangeHandler = _playerRoleChangeHandler;
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
-- Sets the player say text handler.
--
-- @tparam PlayerSayTextHandler _playerSayTextHandler The player say text handler
--
function EventHandler:setPlayerSayTextHandler(_playerSayTextHandler)
  self.playerSayTextHandler = _playerSayTextHandler;
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
-- Sets the player send map handler.
--
-- @tparam PlayerSendMapHandler _playerSendMapHandler The player send map handler
--
function EventHandler:setPlayerSendMapHandler(_playerSendMapHandler)
  self.playerSendMapHandler = _playerSendMapHandler;
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
-- Sets the player spawn handler.
--
-- @tparam PlayerSpawnHandler _playerSpawnHandler The player spawn handler
--
function EventHandler:setPlayerSpawnHandler(_playerSpawnHandler)
  self.playerSpawnHandler = _playerSpawnHandler;
end


return EventHandler;
