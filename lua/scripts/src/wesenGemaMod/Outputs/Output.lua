---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

--
-- Handles outputs to clients.
--
Output = {};

--
-- Display text in the console of a player.
--
-- @param String _text   Text that will be displayed
-- @param int _cn        Player client number
--
function Output:print(_text, _cn)

  -- say to all
  if (_cn == nil) then
    _cn = -1;
  end

  clientprint(_cn,_text);

end

--
-- Outputs the text that a player says to every other player except for himself.
--
-- @param String _text  Text that the player says
-- @param int _cn       Client number of the player
--
function Output:playerSayText(_text, _cn)

  local output = players[_cn]:getName() .. ": " .. _text;
    
  for cn, player in ipairs(players) do
  
    if (cn ~= _cn) then
      self:print(output, cn);
    end
  
  end
  
end

--
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