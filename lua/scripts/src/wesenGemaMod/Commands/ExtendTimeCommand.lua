---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("Commands/BaseCommand");
local Output = require("Outputs/Output");

---
-- Command !extend.
-- Extends the remaining time by a specific amount of time
--
-- @type ExtendTimeCommand
--
local ExtendTimeCommand = {};

-- ExtendTimeCommand inherits from BaseCommand
setmetatable(ExtendTimeCommand, {__index = BaseCommand});


---
-- ExtendTimeCommand constructor.
--
-- @tparam CommandLister _parentCommandLister The parent command lister
--
-- @treturn ExtendTimeCommand The ExtendTimeCommand instance
--
function ExtendTimeCommand:__construct(_parentCommandLister)

  local instance = BaseCommand:__construct(_parentCommandLister, "extend", 1, "Time");
  setmetatable(instance, {__index = ExtendTimeCommand});

  instance:addAlias("ext");
  instance:addAlias("extendTime");
  instance:addArgument("numberOfMinutes", true, "The number of minutes to add to the remaining time");
  instance:setDescription("Extends the remaining time by a specific amount of time.");

  return instance;

end


---
-- Extends the remaining time by a specific amount of time.
--
-- @tparam int _cn The client number of the player who executed the command
-- @tparam string[] _args The list of arguments which were passed by the player
--
function ExtendTimeCommand:execute(_cn, _args)

  local inputTime = tonumber(_args[1]);
  local timeLeft = gettimeleft();
  local errorMessage = false;

  if (inputTime == nil) then
    errorMessage = "[ERROR] The entered number of added minutes is not a number.";
  elseif (inputTime < 1) then
    errorMessage = "[ERROR] The number of added minutes may not be smaller than 1.";
  elseif (timeLeft + inputTime > 35790) then
    errorMessage = "[ERROR] The time remaining may not exceed 35790 minutes.";
  end

  if (errorMessage) then
    Output:print(Output:getColor("error") .. errorMessage, _cn);
    return;
  end

  settimeleft(timeLeft + inputTime);

  local player = self.parentCommandLister:getParentCommandHandler():getParentGemaMod():getPlayers()[_cn];

  Output:print(Output:getColor("info") .. "[INFO] "
            .. Output:getPlayerNameColor(player:getLevel()) .. player:getName()
            .. Output:getColor("info") .. " extended the time by " .. inputTime .. " minutes.");

end


return ExtendTimeCommand;
