---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ColorLoader = require("Colors/ColorLoader");

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

  local player = _players[_cn];
  local playerNameColor = self:getPlayerNameColor(player:getLevel());

  local output = playerNameColor .. player:getName()
              .. self:getColor("playerSayTextCn") .. " (" .. _cn .. ")"
              .. self:getColor("playerSayTextColon") .. ": "
              .. player:getTextColor() .. _text;

  for cn, player in pairs(_players) do

    if (cn ~= _cn) then
      self:print(output, cn);
    end

  end

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
