---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseClientOutput = require("Output/ClientOutput/BaseClientOutput")
local ClientOutputStringSplitter = require("Output/ClientOutput/ClientOutputString/ClientOutputStringSplitter")
local StringUtils = require("Util/StringUtils")

---
-- Represents a output string for the console in the players games.
-- Provides util methods for dealing with the text width of strings.
--
-- @type ClientOutputString
--
local ClientOutputString = setmetatable({}, {__index = BaseClientOutput})


---
-- The raw string
-- The text may not contain the special character "\n"
--
-- @tfield string string
--
ClientOutputString.string = nil

---
-- The cached width of the current raw string in pixels
--
-- @tfield int cachedWidth
--
ClientOutputString.cachedWidth = nil

---
-- The cached next tab stop number for the current raw string
--
-- @tfield int cachedNextTabStopNumber
--
ClientOutputString.cachedNextTabStopNumber = nil

---
-- The client output string splitter
--
-- @tfield ClientOutputStringSplitter splitter
--
ClientOutputString.splitter = nil


-- Metamethods

---
-- ClientOutputString constructor.
--
-- @tparam SymbolWidthLoader _symbolWidthLoader The symbol width loader
-- @tparam TabStopCalculator _tabStopCalculator The tab stop calculator
-- @tparam int _maximumLineWidth The maximum line width
--
-- @treturn ClientOutputString The ClientOutputString instance
--
function ClientOutputString:__construct(_symbolWidthLoader, _tabStopCalculator, _maximumLineWidth)

  local instance = BaseClientOutput(_symbolWidthLoader, _tabStopCalculator, _maximumLineWidth)
  setmetatable(instance, {__index = ClientOutputString})

  instance.splitter = ClientOutputStringSplitter(instance)

  return instance

end

getmetatable(ClientOutputString).__call = ClientOutputString.__construct


-- Getters and Setters

---
-- Sets the cached width.
--
-- @tparam int _cachedWidth The cached width
--
function ClientOutputString:setCachedWidth(_cachedWidth)
  self.cachedWidth = _cachedWidth
end


-- Public Methods

---
-- Parses a string into this ClientOutputString.
--
-- @tparam string _string The string to parse
--
function ClientOutputString:parse(_string)
  self.string = _string:gsub("\n", "")
  self:clearCache()
end

---
-- Returns the number of tabs that this client output's content requires.
--
-- @treturn int The number of required tabs
--
function ClientOutputString:getNumberOfRequiredTabs()
  return self:getNextTabStopNumber()
end

---
-- Returns the minimum number of tabs that this client output's content requires.
--
-- @treturn int The minimum number of required tabs
--
function ClientOutputString:getMinimumNumberOfRequiredTabs()
  return 1
end

---
-- Returns the output rows to display this client output's contents.
--
-- @treturn string[] The output rows
--
function ClientOutputString:getOutputRows()
  return self.splitter:splitStringIntoRows()
end

---
-- Returns the output rows to display this client output's contents wrapped in ClientOutputString's.
--
-- @treturn ClientOutputString[] The output rows
--
function ClientOutputString:getOutputRowsAsClientOutputStrings()
  return self.splitter:splitStringIntoRows(true)
end


---
-- Returns the current raw string.
--
-- @treturn string The current raw string
--
function ClientOutputString:toString()
  return self.string
end

---
-- Right pads the raw string with tabs until it reaches a specific tab stop.
--
-- @tparam int _tabStopNumber The target tab stop number
--
-- @treturn string The string right padded with tabs
--
function ClientOutputString:padWithTabs(_targetTabStopNumber)
  local numberOfTabs = _targetTabStopNumber - self:getNextTabStopNumber() + 1
  return self.string .. string.rep("\t", numberOfTabs)
end

---
-- Splits the raw string into tab groups and returns the result.
--
-- @treturn string[] The tab groups
--
function ClientOutputString:splitIntoTabGroups()
  return StringUtils:split(self.string, "\t", true)
end


-- Private Methods

---
-- Clears the cached values.
--
function ClientOutputString:clearCache()
  self.cachedWidth = nil
  self.cachedNextTabStopNumber = nil
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

---
-- Returns the next tab stop number for the current raw string.
--
-- @treturn int The next tab stop number
--
function ClientOutputString:getNextTabStopNumber()

  if (self.cachedNextTabStopNumber == nil) then
    self.cachedNextTabStopNumber = self.tabStopCalculator:getNextTabStopNumber(self:getWidth())
  end

  return self.cachedNextTabStopNumber

end


return ClientOutputString
