---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Base class for client outputs.
--
-- @type BaseClientOutput
--
local BaseClientOutput = setmetatable({}, {})


---
-- The symbol width loader
--
-- @tfield SymbolWidthLoader symbolWidthLoader
--
BaseClientOutput.symbolWidthLoader = nil

---
-- The tab stop calculator
--
-- @tfield TabStopCalculator tabStopCalculator
--
BaseClientOutput.tabStopCalculator = nil

---
-- The maximum line width in 3x pixels
--
-- @tfield int maximumLineWidth
--
BaseClientOutput.maximumLineWidth = nil

---
-- The maximum number of tabs for this client output
-- This value is based on the maximum line width and vice versa
--
-- @tfield int maximumNumberOfTabs
--
BaseClientOutput.maximumNumberOfTabs = nil

---
-- The indent string for auto line break lines
--
-- @tfield string newLineIndent
--
BaseClientOutput.newLineIndent = nil

---
-- The characters at which the output may be split
-- The output characters will be compared to this string with the "match" method, so this may be a lua expression
--
-- @tfield string lineSplitCharacters
--
BaseClientOutput.lineSplitCharacters = nil


---
-- BaseClientOutput constructor.
--
-- @tparam SymbolWidthLoader _symbolWidthLoader The symbol width loader
-- @tparam TabStopCalculator _tabStopCalculator The tab stop calculator
-- @tparam int _maximumLineWidth The maximum line width
--
-- @treturn BaseClientOutput The BaseClientOutput instance
--
function BaseClientOutput:__construct(_symbolWidthLoader, _tabStopCalculator, _maximumLineWidth)

  local instance = setmetatable({}, {__index = BaseClientOutput})
  instance.symbolWidthLoader = _symbolWidthLoader
  instance.tabStopCalculator = _tabStopCalculator

  instance:changeMaximumLineWidth(_maximumLineWidth)

  return instance

end

getmetatable(BaseClientOutput).__call = BaseClientOutput.__construct


-- Getters and Setters

---
-- Returns the symbol width loader.
--
-- @treturn SymbolWidthLoader The symbol width loader
--
function BaseClientOutput:getSymbolWidthLoader()
  return self.symbolWidthLoader
end

---
-- Returns the tab stop calculator.
--
-- @treturn TabStopCalculator The tab stop calculator
--
function BaseClientOutput:getTabStopCalculator()
  return self.tabStopCalculator
end

---
-- Returns the maximum line width.
--
-- @treturn int The maximum line width
--
function BaseClientOutput:getMaximumLineWidth()
  return self.maximumLineWidth
end

---
-- Returns the maximum number of tabs for this client output.
--
-- @treturn int The maximum number of tabs
--
function BaseClientOutput:getMaximumNumberOfTabs()
  return self.maximumNumberOfTabs
end

---
-- Returns the indent string for auto line break lines.
--
-- @treturn string The indent string
--
function BaseClientOutput:getNewLineIndent()
  return self.newLineIndent
end

---
-- Returns the characters at which the output may be split.
--
-- @treturn string The characters
--
function BaseClientOutput:getLineSplitCharacters()
  return self.lineSplitCharacters
end


-- Public Methods

---
-- Configures this client output.
--
-- @tparam table _configuration The configuration
--
function BaseClientOutput:configure(_configuration)

  if (_configuration["newLineIndent"] ~= nil) then
    self.newLineIndent = _configuration["newLineIndent"]
  end

  if (_configuration["lineSplitCharacters"] ~= nil) then
    self.lineSplitCharacters = _configuration["lineSplitCharacters"]
  end

  if (_configuration["numberOfTabs"] ~= nil) then
    self:changeMaximumNumberOfTabs(tonumber(_configuration["numberOfTabs"]))
  end

end

---
-- Changes the maximum line width to a new value.
--
-- @tparam int The maximum line width
--
function BaseClientOutput:changeMaximumLineWidth(_maximumLineWidth)
  self.maximumLineWidth = _maximumLineWidth
  self.maximumNumberOfTabs = self.tabStopCalculator:getNumberOfPassedTabStops(_maximumLineWidth)
end

---
-- Changes the maximum number of tabs to a new value.
--
-- @tparam int The maximum number of tabs
--
function BaseClientOutput:changeMaximumNumberOfTabs(_maximumNumberOfTabs)
  self.maximumNumberOfTabs = _maximumNumberOfTabs
  self.maximumLineWidth = self.tabStopCalculator:convertTabNumberToPosition(_maximumNumberOfTabs)
end


---
-- Parses a target into this client output.
--
function BaseClientOutput:parse(_target)
end

---
-- Returns the number of tabs that this client output's content requires.
--
-- @treturn int The number of required tabs
--
function BaseClientOutput:getNumberOfRequiredTabs()
end

---
-- Returns the minimum number of tabs that this client output's content requires.
--
-- @treturn int The minimum number of required tabs
--
function BaseClientOutput:getMinimumNumberOfRequiredTabs()
end

---
-- Returns the output rows to display this client output's contents.
--
-- @treturn string[] The output rows
--
function BaseClientOutput:getOutputRows()
end

---
-- Returns the output rows to display this client output's contents wrapped in ClientOutputString's.
--
-- @treturn ClientOutputString[] The output rows
--
function BaseClientOutput:getOutputRowsAsClientOutputStrings()
end


return BaseClientOutput
