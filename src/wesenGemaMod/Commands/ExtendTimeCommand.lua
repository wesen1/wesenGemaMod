---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("CommandHandler/BaseCommand");
local CommandArgument = require("CommandHandler/CommandArgument");
local RemainigTimeExtender = require("TimeHandler/RemainingTimeExtender");

---
-- Command !extend.
-- Extends the remaining time by a specific amount of time
-- ExtendTimeCommand inherits from BaseCommand
--
-- @type ExtendTimeCommand
--
local ExtendTimeCommand = setmetatable({}, {__index = BaseCommand});


---
-- The remaining time extender
--
-- @tfield RemainingTimeExtender remainingTimeExtender
--
ExtendTimeCommand.remainingTimeExtender = nil;


---
-- ExtendTimeCommand constructor.
--
-- @tparam CommandList _parentCommandList The parent command list
--
-- @treturn ExtendTimeCommand The ExtendTimeCommand instance
--
function ExtendTimeCommand:__construct(_parentCommandList)

  local numberOfMinutesArgument = CommandArgument(
    "numberOfMinutes",
    false,
    "integer",
    "min",
    "The number of minutes to add to the remaining time"
  );

  local instance = BaseCommand(
    _parentCommandList,
    "!extend",
    0,
    "Time",
    { numberOfMinutesArgument },
    "Extends the remaining time by a specific amount of time. The time can be extended by 20 minutes per map, but admins may extend the time further than that.",
    { "!ext", "!extendTime" }
  );
  setmetatable(instance, {__index = ExtendTimeCommand});

  -- @todo: Config value "Number of Extend Minutes per map"
  instance.remainingTimeExtender = RemainigTimeExtender(20);

  return instance;

end

getmetatable(ExtendTimeCommand).__call = ExtendTimeCommand.__construct;


-- Public Methods

---
-- Extends the remaining time by a specific amount of time.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
-- @raise Error while extending the time
--
function ExtendTimeCommand:execute(_player, _arguments)

  --@todo: EnvironmentHandler should be in gema mode and not in gema mode state updater
  local environmentHandler = self.parentCommandList:getParentGemaMode():getGemaModeStateUpdater():getEnvironmentHandler();
  local environment = environmentHandler:getCurrentEnvironment();

  self.remainingTimeExtender:extendTime(_player, environment, _arguments.numberOfMinutes);

  -- @todo: Add color for extend minutes?
  self.output:printInfo(
    self.output:getPlayerNameColor(_player:getLevel()) .. _player:getName()
 .. self.output:getColor("info") .. " extended the time by " .. _arguments.numberOfMinutes .. " minutes."
  );

end


return ExtendTimeCommand;
