---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

local ColorLoader = require("Colors/ColorLoader");


---
-- Handles outputs to clients.
--
local Output = {};


---
-- The color loader
-- 
-- @var ColorLoader colorLoader
-- 
Output.colorLoader = ColorLoader:__construct("colors");


---
-- Displays text in the console of a player.
--
-- @param _text (String) The text that will be displayed
-- @param _cn (int) The player client number
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
-- @param _text (String) The text that the player says
-- @param _cn (int) The client number of the player
-- @param _players (Player[]) The list of players
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
-- @param _colorId (String) The name of the color
-- 
-- @return String The color with leading \f
--
function Output:getColor(_colorId)
  return self.colorLoader:loadColor(_colorId);
end

---
-- Calculates and returns the width of text that does not include special characters such as "\n" or "\t".
--
-- @param String _text  The text
--
-- @return int Text width
--
function Output:getTextWidth(_text)

  local textWidth = 0;

  -- exclude "\f_" strings (colors) from width calculation because these characters will not be printed to the screen
  _text = _text:gsub("(%\f[A-Za-z0-9])", "");
    
  for character in _text:gmatch(".") do
    textWidth = textWidth + self:getCharacterWidth(character);
  end
  
  return textWidth;

end

--
-- Returns the width of a single character.
--
-- @param String _character  The character
--
-- @return int Character width
--
function Output:getCharacterWidth(_character)

  local width = cfg.getvalue("font_default", _character);
  
  if (width == nil) then
    width = cfg.getvalue("font_default", "default");
  end

  return width;

end

--
-- Returns tabs to format outputs as a table.
--
-- @return (String) Tabs
--
function Output:getTabs(_entryLength, _longestEntryLength)

  -- Tab width in pixels (1 TabStop = Width of 10 " " or width of 10 default characters
  local tabWidth = 320;
   
  local numberOfTabs = math.ceil(_longestEntryLength / tabWidth);
  local tabsCovered = math.floor(_entryLength / tabWidth);
  local tabsNeeded = numberOfTabs - tabsCovered;
  
  return self:generateTabs(tabsNeeded);
  
end

---
-- Generates a string of tabs
--
-- @param _amountTabs (int) Amount of tabs
-- 
-- @return (String) String of tabs
--
function Output:generateTabs(_amountTabs)

  local tabs = "";

  for i = 1, _amountTabs, 1 do
      tabs = tabs .. "\t";
  end
  
  return tabs;
  
end
    
return Output;
