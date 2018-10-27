---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");
local CommandParser = require("CommandHandler/CommandParser");
local CommandExecutor = require("CommandHandler/CommandExecutor");
local Exception = require("Util/Exception");
local TableUtils = require("Util/TableUtils");

---
-- Class that handles players saying texts.
-- PlayerSayTextHandler inherits from BaseEventHandler
--
-- @type PlayerSayTextHandler
--
local PlayerSayTextHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- The command parser
--
-- @tfield CommandParser commandParser
--
PlayerSayTextHandler.commandParser = nil;

---
-- The command executor
--
-- @tfield CommandExecutor commandExecutor
--
PlayerSayTextHandler.commandExecutor = nil;


---
-- PlayerSayTextHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn PlayerSayTextHandler The PlayerSayTextHandler instance
--
function PlayerSayTextHandler:__construct(_parentGemaMode)

  local instance = BaseEventHandler(_parentGemaMode);
  setmetatable(instance, {__index = PlayerSayTextHandler});

  instance.commandParser = CommandParser(instance.output);
  instance.commandExecutor = CommandExecutor();

  return instance;

end

getmetatable(PlayerSayTextHandler).__call = PlayerSayTextHandler.__construct;


-- Public Methods

---
-- Event handler which is called when a player says text.
-- Logs the text that the player said and either executes a command or outputs the text to the other players
--
-- @tparam int _player The player
-- @tparam string _text The text that the player sent
--
-- @treturn int|nil PLUGIN_BLOCK if the gema mode is active or nil
--
function PlayerSayTextHandler:onPlayerSayText(_player, _text)

  local logText = string.format("[%s] %s says: '%s'", _player:getIp(), _player:getName(), _text);
  logline(ACLOG_INFO, logText);

  if (self.parentGemaMode:getIsActive()) then

    if (self.commandParser:isCommand(_text)) then

      local status, exception = pcall(self.handleCommand, self, _player, _text);
      if (not status) then
        if (TableUtils:isInstanceOf(exception, Exception)) then
          self.output:printError(exception:getMessage(), _player);
        else
          error(exception);
        end
      end

    else
      local players = self.parentGemaMode:getPlayerList():getPlayers();
      self.output:playerSayText(_text, _player:getCn(), players);
    end

    -- block the normal player text output of the server
    return PLUGIN_BLOCK;

  end

end

---
-- Handles a command input of a player.
--
-- @tparam Player _player The player who used a command
-- @tparam string _text The text that the player said
--
-- @raise Error while parsing the command
-- @raise Error while executing the command
--
function PlayerSayTextHandler:handleCommand(_player, _text)

  self.commandParser:parseCommand(_text, self.parentGemaMode:getCommandList());

  local command = self.commandParser:getCommand();
  local arguments = self.commandParser:getArguments();
  self.commandExecutor:executeCommand(command, arguments, _player);

end


return PlayerSayTextHandler;
