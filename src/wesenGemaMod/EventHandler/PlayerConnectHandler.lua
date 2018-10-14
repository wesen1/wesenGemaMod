---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");

---
-- Class that handles player connects.
-- PlayerConnectHandler inherits from BaseEventHandler
--
-- @type PlayerConnectHandler
--
local PlayerConnectHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- The maximum allowed number of connections with the same ip to the server
--
-- @tfield int maximumNumberOfConnectionsWithSameIp
--
PlayerConnectHandler.maximumNumberOfConnectionsWithSameIp = nil;


---
-- PlayerConnectHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn PlayerConnectHandler The PlayerConnectHandler instance
--
function PlayerConnectHandler:__construct(_parentGemaMode)

  local instance = BaseEventHandler(_parentGemaMode);
  setmetatable(instance, {__index = PlayerConnectHandler});

  -- @todo: Add config value for this
  instance.maximumNumberOfConnectionsWithSameIp = 2;

  return instance;

end

getmetatable(PlayerConnectHandler).__call = PlayerConnectHandler.__construct;


-- Public Methods

---
-- Event handler which is called when a player connects.
--
-- @tparam int _cn The client number of the player who connected
--
function PlayerConnectHandler:onPlayerConnect(_cn)

  local dataBase = self.parentGemaMode:getDataBase();
  local playerList = self.parentGemaMode:getPlayerList();
  
  -- Add the player to the player list
  playerList:addPlayer(dataBase, _cn);

  -- Get the Player object for the new connected player
  local player = playerList:getPlayer(_cn);

  if (self.parentGemaMode:getIsActive()) then

    if (#playerList:getPlayers() == 1) then
      setautoteam (false);
    end

    self:checkNumberOfConnections(player);
    self:printServerInformation(player);

  else
    self.output:printInfo("The gema mode is not enabled. Vote a gema map in ctf to enable it.", player);
  end

end


-- Private Methods

---
-- Checks the amount of connections of a specific ip.
-- If there are too many connections the new connected player will be kicked.
--
-- @tparam Player player The player who connected
--
function PlayerConnectHandler:checkNumberOfConnections(player)
  
  local playerList = self.parentGemaMode:getPlayerList();

  local numberOfPlayerConnections = playerList:getNumberOfPlayersWithIp(player:getIp());
  if (numberOfPlayerConnections > self.maximumNumberOfConnectionsWithSameIp) then

    self.output:printInfo(player:getName() .. " could not connect [too many connections with same IP]");
    playerList:removePlayer(player:getCn());
    disconnect(player:getCn(), DISC_NONE);

  end

end

---
-- Prints the map statistics and information about the commands to a player.
--
-- @tparam Player _player The player who connected
--
function PlayerConnectHandler:printServerInformation(_player)

  local mapTopHandler = self.parentGemaMode:getMapTopHandler();
  local mapTop = mapTopHandler:getMapTop("main");
  mapTopHandler:getMapTopPrinter():printMapStatistics(mapTop, _player);

  self.output:print(self.output:getColor("info") .. "Say "
                 .. self.output:getColor("command0") .. "!cmds "
                 .. self.output:getColor("info") .. "to see a list of avaiable commands",
                 _player);
  self.output:print(self.output:getColor("infoWarning") .. "Make sure to read the "
                 .. self.output:getColor("command0") .. "!rules "
                 .. self.output:getColor("infoWarning") .. "before spawning",
                 _player);

end


return PlayerConnectHandler;
