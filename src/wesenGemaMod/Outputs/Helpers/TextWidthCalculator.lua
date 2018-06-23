---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Calculates the text width of a text in pixels.
--
-- @type TextWidthCalculator
--
local TextWidthCalculator = {};


---
-- The name of the font config file
--
-- @tfield string fontConfigFileName
--
TextWidthCalculator.fontConfigFileName = "";

---
-- The font pixel widths in the format {[character] = width}
--
-- @tfield int[] cachedFontConfig
--
TextWidthCalculator.cachedFontConfig = false;


---
-- TextWidthCalcuator constructor.
--
-- @tparam string _fontConfigFileName The name of the font config in the "lua/config" folder
-- @tparam Bool _cacheFontConfig True: The font config will be loaded once and is then saved in a variable
--                               False: The font config will be loaded from the .cfg file each time it is used
--
-- @treturn TextWidthCalculator The TextWidthCalculator instance
--
function TextWidthCalculator:__construct(_fontConfigFileName, _cacheFontConfig)

  local instance = {};
  setmetatable(instance, { __index = TextWidthCalculator });

  instance.fontConfigFileName = _fontConfigFileName;

  if (_cacheFontConfig) then

    instance.cachedFontConfig = {};
    for index, width in pairs(cfg.totable(_fontConfigFileName)) do
      instance.cachedFontConfig[index] = tonumber(width);
    end

  end

  return instance;

end

---
-- Calculates and returns the width of _text.
-- The text may not contain the special characters "\n" and "\t".
-- The function automatically removes "\f<colorId>" parts of strings. 
--
-- @tparam string _text The text
--
-- @treturn int The text width
--
function TextWidthCalculator:getTextWidth(_text)

  local textWidth = 0;

  -- exclude "\f_" strings (colors) from width calculation because these characters will not be printed to the screen
  local text = _text:gsub("(%\f[A-Za-z0-9])", "");

  for character in text:gmatch(".") do
    textWidth = textWidth + self:getCharacterWidth(character);
  end

  return textWidth;

end

---
-- Loads and returns the width of a character in pixels.
--
-- @tparam string _character The character
--
-- @treturn int The character width
--
function TextWidthCalculator:getCharacterWidth(_character)

  local character = _character;
  if (character == " ") then
    character = "whitespace";
  end

  if (self.cachedFontConfig) then
    return self:getCharacterWidthFromCachedFontConfig(character);
  else
    return self:getCharacterWidthFromConfigFile(character);
  end

end

---
-- Loads and returns the character width in pixels from the cached font config.
--
-- @tparam string _character The character
--
-- @treturn int The character width
--
function TextWidthCalculator:getCharacterWidthFromCachedFontConfig(_character)

  local width = self.cachedFontConfig[_character];
  if (width == nil) then
    width = self.cachedFontConfig["default"]
  end

  return width;

end

---
-- Loads and returns the character width in pixels from the config file.
--
-- @tparam string _character The character
--
-- @treturn int The character width
--
function TextWidthCalculator:getCharacterWidthFromConfigFile(_character)

  local width = cfg.getvalue(self.fontConfigFileName, _character);
  if (width == nil) then
    width = cfg.getvalue(self.fontConfigFileName, "default");
  end

  return tonumber(width);

end


return TextWidthCalculator;
