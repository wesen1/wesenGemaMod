---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local StringUtils = require("Util/StringUtils");
local SymbolWidthLoader = require("Output/TableRenderer/TextWidthCalculator/SymbolWidthLoader");
local TabStopCalculator = require("Output/TableRenderer/TabStopCalculator");

---
-- Calculates the text width of a text in pixels.
--
-- @type TextWidthCalculator
--
local TextWidthCalculator = setmetatable({}, {});


---
-- The symbol width loader
--
-- @tfield SymbolWidthLoader symbolWidthLoader
--
TextWidthCalculator.symbolWidthLoader = nil;

---
-- The tab stop calculator
--
-- @tfield TabStopCalculator tabStopCalculator
--
TextWidthCalculator.tabStopCalculator = nil;


---
-- TextWidthCalcuator constructor.
--
-- @tparam string _fontConfigFileName The name of the font config in the "lua/config" folder
--
-- @treturn TextWidthCalculator The TextWidthCalculator instance
--
function TextWidthCalculator:__construct(_fontConfigFileName)

  local instance = setmetatable({}, {__index = TextWidthCalculator});

  instance.symbolWidthLoader = SymbolWidthLoader(_fontConfigFileName, true);
  instance.tabStopCalculator = TabStopCalculator(instance.symbolWidthLoader:getCharacterWidth("\t"));

  return instance;

end

getmetatable(TextWidthCalculator).__call = TextWidthCalculator.__construct;


-- Public Methods

---
-- Calculates and returns the width of _text.
-- The text may not contain the special character "\n".
--
-- @tparam string _text The text
--
-- @treturn int The text width in pixels
--
function TextWidthCalculator:getTextWidth(_text)

  -- Exclude "\f*" strings (colors) from width calculation because these characters will not be printed to the screen
  --@todo: What happens if player or mapname contains \fx?
  local text = _text:gsub("(%\f[A-Za-z0-9])", "");

  local textWidth = 0;
  local textParts = StringUtils:split(text, "\t", true);
  local numberOfTextParts = #textParts;

  for i = 1, numberOfTextParts - 1, 1 do

    -- Calculate the text part width
    textWidth = textWidth + self:getTextPartWidth(textParts[i]);

    -- Jump to the next tab stop
    textWidth = self.tabStopCalculator:getNextTabStopPosition(textWidth);

  end

  textWidth = textWidth + self:getTextPartWidth(textParts[numberOfTextParts]);

  return textWidth;

end

---
-- Returns the width of a character in pixels.
--
-- @tparam string _character The character
--
-- @treturn int The character width in pixels
--
function TextWidthCalculator:getCharacterWidth(_character)
  return self.symbolWidthLoader:getCharacterWidth(_character);
end


-- Private Methods

---
-- Returns the width of a text part in pixels.
-- The text part may not contain tabs or "\f*" (color strings).
--
-- @tparam string _textPart The text part
--
-- @treturn int The width of the text part in pixels
--
function TextWidthCalculator:getTextPartWidth(_textPart)

  local textPartWidth = 0;
  for character in _textPart:gmatch(".") do
    textPartWidth = textPartWidth + self.symbolWidthLoader:getCharacterWidth(character);
  end

  return textPartWidth;

end


return TextWidthCalculator;
