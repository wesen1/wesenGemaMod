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

  local instance = BaseCommand:__construct(_parentCommandLister, "extend", 0, "Time");
  setmetatable(instance, {__index = ExtendTimeCommand});

  instance:addAlias("ext");
  instance:addAlias("extendTime");
  instance:addArgument("numberOfMinutes", true, "The number of minutes to add to the remaining time");
  instance:setDescription("Extends the remaining time by a specific amount of time. The time can be extended by 20 minutes per map, but admins may extend the time further than that.");

  return instance;

end


---
-- Extends the remaining time by a specific amount of time.
--
-- @tparam int _cn The client number of the player who executed the command
-- @tparam string[] _args The list of arguments which were passed by the player
--
function ExtendTimeCommand:execute(_cn, _args)

  local inputMinutes = tonumber(_args[1]);
  local errorMessage = self:checkInputMinutes(inputMinutes);

  local parentGemaMod = self.parentCommandLister:getParentCommandHandler():getParentGemaMod();
  local player = parentGemaMod:getPlayers()[_cn];

  if (not errorMessage) then
    errorMessage = self:subtractMinutesFromRemainingExtendMinutes(player, inputMinutes);
  end

  if (errorMessage) then
    Output:print(Output:getColor("error") .. errorMessage, _cn);
    return;
  end

  settimeleft(gettimeleft() + inputMinutes);


  Output:print(Output:getColor("info") .. "[INFO] "
            .. Output:getPlayerNameColor(player:getLevel()) .. player:getName()
            .. Output:getColor("info") .. " extended the time by " .. inputMinutes .. " minutes.");

end

---
-- Checks whether the input minutes are valid.
--
-- @tparam int _inputMinutes The input minutes
--
-- @treturn string|nil The error message or nil
--
function ExtendTimeCommand:checkInputMinutes(_inputMinutes)

  local timeLeft = gettimeleft();
  local errorMessage = nil;

  if (_inputMinutes == nil) then
    errorMessage = "[ERROR] The entered number of added minutes is not a number.";
  elseif (_inputMinutes < 1) then
    errorMessage = "[ERROR] The number of added minutes may not be smaller than 1.";
  elseif (timeLeft + _inputMinutes > 35790) then
    errorMessage = "[ERROR] The time remaining may not exceed 35790 minutes.";
  end

  return errorMessage;

end

---
-- Subtracts _inputMinutes from the remainig extend minutes.
-- Returns an error if the amount of minutes exceeds the remaining extend minutes.
--
-- @tparam Player _player The player who used !extend
-- @tparam int _inputMinutes The input minutes
--
-- @treturn string|nil The error message or nil
--
function ExtendTimeCommand:subtractMinutesFromRemainingExtendMinutes(_player, _inputMinutes)

  local parentGemaMod = self.parentCommandLister:getParentCommandHandler():getParentGemaMod();
  local errorMessage = nil;

  if (_player:getLevel() == 0) then

    local remainingExtendMinutes = parentGemaMod:getRemainingExtendMinutes();

    if (remainingExtendMinutes == 0) then
      errorMessage = "[ERROR] The time may not be further extended. Ask an admin to extend the time.";
    elseif (remainingExtendMinutes < _inputMinutes) then
      errorMessage = "[ERROR] The time may be extended by only " .. remainingExtendMinutes .. " more minutes.";
    else
      parentGemaMod:setRemainingExtendMinutes(remainingExtendMinutes - _inputMinutes);
    end

  end

  return errorMessage;

end


return ExtendTimeCommand;
