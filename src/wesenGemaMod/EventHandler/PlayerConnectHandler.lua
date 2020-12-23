---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");
local StaticString = require("Output/StaticString");

---
-- Class that handles player connects.
-- PlayerConnectHandler inherits from BaseEventHandler
--
-- @type PlayerConnectHandler
--
local PlayerConnectHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- PlayerConnectHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn PlayerConnectHandler The PlayerConnectHandler instance
--
function PlayerConnectHandler:__construct(_parentGemaMode)

  local instance = BaseEventHandler(_parentGemaMode, "onPlayerConnect");
  setmetatable(instance, {__index = PlayerConnectHandler});

  return instance;

end

getmetatable(PlayerConnectHandler).__call = PlayerConnectHandler.__construct;


-- Public Methods

---
-- Event handler which is called when a player connects.
--
-- @tparam int _cn The client number of the player who connected
--
function PlayerConnectHandler:handleEvent(_cn)

  local playerList = self.parentGemaMode:getPlayerList();

  -- Add the player to the player list
  playerList:addPlayer(_cn);

  -- Get the Player object for the new connected player
  local player = playerList:getPlayer(_cn);

  if (self.parentGemaMode:getIsActive()) then

    if (#playerList:getPlayers() == 1) then
      setautoteam (false);
    end

    self:printServerInformation(player);

  else
    self.output:printTextTemplate("TextTemplate/InfoMessages/GemaModeState/GemaModeNotEnabled", {}, player)
  end

end


-- Private Methods

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


return PlayerConnectHandler;
