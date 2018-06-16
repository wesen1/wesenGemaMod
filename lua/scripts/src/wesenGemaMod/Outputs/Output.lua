---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ColorLoader = require("Outputs/Helpers/ColorLoader");

---
-- Handles outputs of texts to clients.
--
-- @type Output
--
local Output = {};


---
-- The color loader
--
-- @tfield ColorLoader colorLoader
--
Output.colorLoader = ColorLoader:__construct("colors");


-- Getters and setters

---
-- Returns the color loader.
--
-- @treturn ColorLoader The color loader
--
function Output:getColorLoader()
  return self.colorLoader;
end

---
-- Sets the color loader.
--
-- @tparam ColorLoader _colorLoader The color loader
--
function Output:setColorLoader(_colorLoader)
  self.colorLoader = _colorLoader;
end


-- Class Methods

---
-- Displays text in the console of a player.
--
-- @tparam string _text The text that will be displayed
-- @tparam int _cn The player client number
--
function Output:print(_text, _cn)

  -- say to all
  if (_cn == nil) then
    _cn = -1;
  end

  clientprint(_cn,_text);

end

---
-- Outputs the text that a player says to every other player except for himself.
--
-- @tparam string _text The text that the player says
-- @tparam int _cn The client number of the player
-- @tparam Player[] _players The list of players
--
function Output:playerSayText(_text, _cn, _players)

  sayas(_text, _cn, false, false); 

  --[[
  local player = _players[_cn];
  local playerNameColor = self:getPlayerNameColor(player:getLevel());

  -- make the output look exactly like the assaultcube output by only showing the cn when the name is not unique
  local cnString = "";
  if (not self:isPlayerNameUnique(_cn, _players)) then
    cnString = " (" .. _cn .. ")";
  end

  local output = playerNameColor .. player:getName()
              .. self:getColor("playerSayTextCn") .. cnString
              .. self:getColor("playerSayTextColon") .. ": "
              .. player:getTextColor() .. _text;

  for cn, player in pairs(_players) do

    if (cn ~= _cn) then
      self:print(output, cn);
    end

  end
  --]]

end

--[[
---
-- Returns whether a player name is unique in the list of players.
--
-- @tparam int _cn The client number of the player
-- @tparam Player[] _players The list of players
--
-- @treturn bool True: The player name is unique
--               False: Multiple players have the players name
--
function Output:isPlayerNameUnique(_cn, _players)

  for cn, player in pairs(_players) do

    if (cn ~= _cn and player:getName() == _players[_cn]:getName()) then
        return false;
    end

  end

  return true;

end

--]]

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
    return Output:getColor("teamRVSF");
  elseif (_teamId == TEAM_CLA) then
    return Output:getColor("teamCLA");
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
