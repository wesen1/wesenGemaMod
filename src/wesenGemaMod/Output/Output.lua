---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ColorLoader = require("Output/Util/ColorLoader");
local TableRenderer = require("Output/Util/TableRenderer");


--@todo: Add text templates for all texts because annoying getColor("") calls

---
-- Handles outputs of texts to clients.
--
-- @type Output
--
local Output = setmetatable({}, {});


---
-- The color loader
--
-- @tfield ColorLoader colorLoader
--
Output.colorLoader = nil;

---
-- The table renderer
--
-- @tfield TableRenderer tableRenderer
--
Output.tableRenderer = nil;


---
-- Output constructor.
--
-- @treturn Output The Output instance
--
function Output:__construct()

  local instance = setmetatable({}, { __index = Output });

  -- @todo: Config value for color scheme name
  instance.colorLoader = ColorLoader("colors");
  instance.tableRenderer = TableRenderer();

  return instance;

end

getmetatable(Output).__call = Output.__construct;


-- Public Methods

---
-- Displays text in the console of a player.
--
-- @tparam string _text The text that will be displayed
-- @tparam Player _player The player
--
function Output:print(_text, _player)

  -- -1 targets all connected players
  local cn = -1;

  if (_player ~= nil) then
    cn = _player:getCn();
  end

  clientprint(cn,_text);

end

---
-- Displays a error message in the console of a player.
--
-- @tparam string _errorText The error text that will be displayed
-- @tparam int _player The player
--
function Output:printError(_errorText, _player)
  self:print(self:getColor("error") .. "[ERROR] " .. _errorText, _player);
end

---
-- Displays a info message in the console of a player.
--
-- @tparam string _infoText The info text that will be displayed
-- @tparam int _player The player
--
function Output:printInfo(_infoText, _player)
  self:print(self:getColor("info") .. "[INFO] " .. _infoText, _player);
end

---
-- Prints a table to a player.
--
-- @tparam table _table The table
-- @tparam Player _player The player to print the table to
-- @tparam bool _isOneDimensionalTable Defines whether the table is one or multi dimensional
--
function Output:printTable(_table, _player, _isOneDimensionalTable)

  for index, rowOutputString in ipairs(self.tableRenderer:getRowOutputStrings(_table, _isOneDimensionalTable)) do
    self:print(rowOutputString, _player);
  end

end

---
-- Outputs the text that a player says to every other player except for himself.
--
-- @tparam string _text The text that the player says
-- @tparam int _cn The client number of the player
--
function Output:playerSayText(_text, _player)

  -- sayas is used here so that the players can still use local commands like ignore
  sayas(_text, _player, false, false);
end

---
-- Returns the player name color based on the players level.
--
-- @tparam int _playerLevel The level of the player
--
-- @treturn string The color for the name
--
function Output:getPlayerNameColor(_playerLevel)

  if (_playerLevel == 0) then
    return self:getColor("nameUnarmed");
  elseif (_playerLevel == 1) then
    return self:getColor("nameAdmin");
  end

end

---
-- Returns the color for a team.
--
-- @tparam int _teamId The team id
--
-- @treturn string The team color
--
function Output:getTeamColor(_teamId)

  if (_teamId == TEAM_RVSF) then
    return self:getColor("teamRVSF");
  elseif (_teamId == TEAM_CLA) then
    return self:getColor("teamCLA");
  end

end

---
-- Loads a color from the color config file.
--
-- @tparam string _colorId The name of the color
--
-- @treturn string The color with leading "\f"
--
function Output:getColor(_colorId)
  return self.colorLoader:loadColor(_colorId);
end


return Output;
