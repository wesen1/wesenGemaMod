---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ClientOutputStringSplitter = require("Output/ClientOutputString/ClientOutputStringSplitter")
local StringUtils = require("Util/StringUtils")
local TabStopCalculator = require("Output/ClientOutputString/TabStopCalculator")

---
-- Represents a output string for the console in the players games.
-- Provides util methods for dealing with the text width of strings.
--
-- @type ClientOutputString
--
local ClientOutputString = setmetatable({}, {})


---
-- The raw string
-- The text may not contain the special character "\n"
--
-- @tparam string string
--
ClientOutputString.string = nil

---
-- The symbol width loader
--
-- @tfield SymbolWidthLoader symbolWidthLoader
--
ClientOutputString.symbolWidthLoader = nil

---
-- The tab stop calculator
--
-- @tfield TabStopCalculator tabStopCalculator
--
ClientOutputString.tabStopCalculator = nil

---
-- The cached width of the current raw string in pixels
--
-- @tparam int cachedWidth
--
ClientOutputString.cachedWidth = nil


-- Metamethods

---
-- ClientOutputString constructor.
--
-- @tparam SymbolWidthLoader _symbolWidthLoader The symbol width loader
-- @tparam string _string The raw string
--
-- @treturn ClientOutputString The ClientOutputString instance
--
function ClientOutputString:__construct(_symbolWidthLoader, _string)

  local instance = setmetatable({}, {__index = ClientOutputString})

  instance.string = _string:gsub("\n", "")
  instance.symbolWidthLoader = _symbolWidthLoader
  instance.tabStopCalculator = TabStopCalculator(instance.symbolWidthLoader:getCharacterWidth("\t"))

  return instance

end

getmetatable(ClientOutputString).__call = ClientOutputString.__construct


-- Public Methods

---
-- Returns the current raw string.
--
-- @treturn string The current raw string
--
function ClientOutputString:toString()
  return self.string
end

---
-- Returns the width of the raw string in pixels.
--
-- @treturn int The width of the raw string in pixels
--
function ClientOutputString:getWidth()

  if (self.cachedWidth == nil) then
    self.cachedWidth = self:calculateWidth()
  end

  return self.cachedWidth

end

---
-- Pads the raw string with tabs until the tab stop before a specific pixel.
--
-- @tparam int _pixelNumber The pixel number
--
function ClientOutputString:padUntilTabStopBeforePixel(_pixelNumber)

  local targetTabStopPosition = self.tabStopCalculator:getLastPassedTabStopPosition(_pixelNumber)
  local numberOfTabs = self.tabStopCalculator:getNumberOfTabsToTabStop(self:getWidth(), targetTabStopPosition)

  self.string = self.string .. string.rep("\t", numberOfTabs)
  self.cachedWidth = nil

end

---
-- Splits the raw string into tab groups and returns the result.
--
-- @treturn string[] The tab groups
--
function ClientOutputString:splitIntoTabGroups()
  return StringUtils:split(self.string, "\t", true)
end

---
-- Splits the raw string into pixel groups and returns the result.
--
-- @tparam int _numberOfPixelsPerGroup The number of pixels per pixel group
-- @tparam bool _splitAtWhitespace Whether to split the string at whitespaces or any character
--
-- @treturn string[] The pixel groups
--
function ClientOutputString:splitIntoIntoPixelGroups(_numberOfPixelsPerGroup, _splitAtWhitespace)
  local splitter = ClientOutputStringSplitter(self.symbolWidthLoader, self.tabStopCalculator)
  return splitter:splitStringIntoPixelGroups(self, _numberOfPixelsPerGroup, _splitAtWhitespace)
end


-- Private Methods

---
-- Calculates and returns the width of the raw string in pixels.
--
-- @treturn int The width of the raw string in pixels
--
function ClientOutputString:calculateWidth()

  local tabGroups = self:splitIntoTabGroups()
  local numberOfTabGroups = #tabGroups

  local totalWidth = 0
  for i, tabGroup in ipairs(tabGroups) do

    -- Calculate the text part width
    totalWidth = totalWidth + self:getStringWidth(tabGroup)

    if (i < numberOfTabGroups) then
      -- Jump to the next tab stop
      totalWidth = self.tabStopCalculator:getNextTabStopPosition(totalWidth);
    end

  end

  return totalWidth

end

---
-- Returns the width of a string in pixels.
--
-- @tparam string _string The string
--
-- @treturn int The width of the string in pixels
--
function ClientOutputString:getStringWidth(_string)

  -- Remove "\f*" strings (colors) because these characters will not be printed to the screen
  local targetString = _string:gsub("(%\f[A-Za-z0-9])", "")

  local width = 0
  for character in targetString:gmatch(".") do
    width = width + self.symbolWidthLoader:getCharacterWidth(character)
  end

  return width

end


return ClientOutputString
