
---
-- Event handler which is called when a player connects.
--
-- @tparam int _cn The client number of the player who connected
--
function PlayerConnectHandler:handleEvent(_cn)

  instance.maximumNumberOfConnectionsWithSameIp = 2;

  local playerList = self.parentGemaMode:getPlayerList();

  -- Add the player to the player list
  playerList:addPlayer(_cn);

  -- Get the Player object for the new connected player
  local player = playerList:getPlayer(_cn);

  if (self.parentGemaMode:getIsActive()) then

    if (#playerList:getPlayers() == 1) then
      setautoteam (false);
    end

    self:checkNumberOfConnections(player);
    self:printServerInformation(player);

  else
    self.output:printTextTemplate("TextTemplate/InfoMessages/GemaModeState/GemaModeNotEnabled", {}, player)
  end

end


-- Private Methods

---
-- Checks the amount of connections of a specific ip.
-- If there are too many connections the new connected player will be kicked.
--
-- @tparam Player player The player who connected
--
function PlayerConnectHandler:checkNumberOfConnections(_player)

  local playerList = self.parentGemaMode:getPlayerList();

  local numberOfPlayerConnections = playerList:getNumberOfPlayersWithIp(_player:getIp());
  if (numberOfPlayerConnections > self.maximumNumberOfConnectionsWithSameIp) then

    self.output:printTextTemplate(
      "TextTemplate/InfoMessages/Player/PlayerDisconnectTooManyConnections", { ["player"] = _player }
    )
    playerList:removePlayer(_player:getCn());
    disconnect(_player:getCn(), DISC_NONE);

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

  self.output:printTableTemplate(
    "TableTemplate/MapTop/MapStatistics",
    { ["mapRecordList"] = mapTop:getMapRecordList() },
    _player
  )

  local commandList = self.parentGemaMode:getCommandList();
  local cmdsCommand = commandList:getCommand(StaticString("cmdsCommandName"):getString());
  local rulesCommand = commandList:getCommand(StaticString("rulesCommandName"):getString());

  self.output:printTableTemplate(
    "TableTemplate/ServerInformation",
    { ["cmdsCommand"] = cmdsCommand, ["rulesCommand"] = rulesCommand },
    _player
  )

end
