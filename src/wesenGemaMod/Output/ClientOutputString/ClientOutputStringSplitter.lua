---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local StringUtils = require("Util/StringUtils")
local TableUtils = require("Util/TableUtils")

---
-- Provides methods to split a ClientOutputString into string groups.
--
-- @type ClientOutputStringSplitter
--
local ClientOutputStringSplitter = setmetatable({}, {})


---
-- The symbol width loader
--
-- @tfield SymbolWidthLoader symbolWidthLoader
--
ClientOutputStringSplitter.symbolWidthLoader = nil

---
-- The tabstop calculator
--
-- @tfield TabStopCalculator tabStopCalculator
--
ClientOutputStringSplitter.tabStopCalculator = nil


-- Attributes for the string split loop

---
-- The list of remaining tab groups
--
-- @tfield string[] remainingTabGroups
--
ClientOutputStringSplitter.remainingTabGroups = nil

---
-- The current color string
-- This is prepended to each row in order to keep the color from the previous row
--
-- @tfield string currentColorString
--
ClientOutputStringSplitter.currentColorString = nil

---
-- The whitespace positions
-- This is needed to split the string at the last possible whitespace position
--
-- The table is in the format { { [tabGroupNumber] = int, [characterNumber] = int }, ... }
--
-- @tfield table[] whitespacePositions
--
ClientOutputStringSplitter.whitespacePositions = nil

---
-- The current tab group number
--
-- @tfield int currentTabGroupNumber
--
ClientOutputStringSplitter.currentTabGroupNumber = nil

---
-- The current character position in the current tab group
--
-- @tfield int currentCharacterNumber
--
ClientOutputStringSplitter.currentCharacterNumber = nil


---
-- ClientOutputStringSplitter constructor.
--
-- @tparam SymbolWidthLoader _symbolWidthLoader The symbol width loader
-- @tparam TabStopCalculator _tabStopCalculator The tabstop calculator
--
-- @treturn ClientOutputStringSplitter The ClientOutputStringSplitter instance
--
function ClientOutputStringSplitter:__construct(_symbolWidthLoader, _tabStopCalculator)

  local instance = setmetatable({}, {__index = ClientOutputStringSplitter})

  instance.symbolWidthLoader = _symbolWidthLoader
  instance.tabStopCalculator = _tabStopCalculator

  return instance

end

getmetatable(ClientOutputStringSplitter).__call = ClientOutputStringSplitter.__construct


-- Public Methods

---
-- Splits a ClientOutputString into pixel groups.
--
-- @tparam ClientOutputString _clientOutputString The ClientOutputString
-- @tparam int _numberOfPixelsPerGroup The number of pixels per pixel group
-- @tparam bool _splitAtWhitespace Whether to split the string at whitespaces or any character
--
-- @treturn string[] The pixel groups
--
function ClientOutputStringSplitter:splitStringIntoPixelGroups(_clientOutputString, _numberOfPixelsPerGroup, _splitAtWhitespace)

  self.remainingTabGroups = _clientOutputString:splitIntoTabGroups()
  self.currentColorString = ""

  local rowStrings = {}
  while (#self.remainingTabGroups > 0) do

    local rowString = self.currentColorString

    -- Calculate the maximum end position of the next pixel group
    if (_splitAtWhitespace) then
      self.whitespacePositions = {}
    end
    self:calculateNextPixelGroupEndPosition(_numberOfPixelsPerGroup, _splitAtWhitespace)

    -- Fetch the next pixel group string
    table.insert(rowStrings, rowString .. self:getNextPixelGroupString(_splitAtWhitespace))

    -- Remove the pixel group string from the remaining tab groups
    self:removeCurrentPixelGroupFromRemainingTabGroups()

  end

  return rowStrings

end


-- Private Methods

---
-- Calculates the maximum end position of the next pixel group and saves the result in
-- the attributes currentTabGroupNumber and currentCharacterNumber.
--
-- @tparam int _maximumNumberOfPixels The maximum number of pixels per pixel group
-- @tparam bool _splitAtWhitespace Whether to split the string at whitespaces or any character
--
function ClientOutputStringSplitter:calculateNextPixelGroupEndPosition(_maximumNumberOfPixels, _splitAtWhitespace)

  local currentRowWidth = 0

  for tabGroupNumber, tabGroup in ipairs(self.remainingTabGroups) do

    self.currentTabGroupNumber = tabGroupNumber
    self.currentCharacterNumber = 1

    local colorPositions = StringUtils.findAllSubStringOccurrences(tabGroup, "%\f[A-Za-z0-9]")
    local numberOfColorPositions = #colorPositions

    local currentColorPosition = nil
    if (numberOfColorPositions > 0) then
      currentColorPosition = 1
    end

    for i, character in ipairs(StringUtils.splitIntoCharacters(tabGroup)) do

      -- Necessary for skipping some loop cycles
      if (i == self.currentCharacterNumber) then

        if (currentColorPosition ~= nil and
            self.currentCharacterNumber == colorPositions[currentColorPosition]["start"]) then

          -- Set the current color string
          self.currentColorString = tabGroup:sub(
            colorPositions[currentColorPosition]["start"],
            colorPositions[currentColorPosition]["end"]
          )

          -- Jump to the position behind the color string
          self.currentCharacterNumber = colorPositions[currentColorPosition]["end"] + 1

          if (numberOfColorPositions > currentColorPosition) then
            currentColorPosition = currentColorPosition + 1
          else
            currentColorPosition = nil
          end

        else

          if (_splitAtWhitespace and character == " ") then
            table.insert(
              self.whitespacePositions, {
                ["tabGroupNumber"] = self.currentTabGroupNumber,
                ["characterNumber"] = self.currentCharacterNumber
            })
          end

          -- Get the width of the current character
          local currentCharacterWidth = self.symbolWidthLoader:getCharacterWidth(character)

          -- Check if the new total width exceeds the maximum allowed width
          if (currentRowWidth + currentCharacterWidth > _maximumNumberOfPixels) then
            return
          else
            self.currentCharacterNumber = self.currentCharacterNumber + 1
            currentRowWidth = currentRowWidth + currentCharacterWidth
          end

        end

      end

    end

    -- Jump to the next tab stop
    currentRowWidth = self.tabStopCalculator:getNextTabStopPosition(currentRowWidth)

  end

end

---
-- Returns the next pixel group string.
-- Uses the currentTabGroupNumber and currentCharacterNumber attributes to extract the string.
--
-- @tparam bool _splitAtWhitespace Whether to split the string at whitespaces or any character
--
-- @treturn string The next pixel group string
--
function ClientOutputStringSplitter:getNextPixelGroupString(_splitAtWhitespace)

  -- Adjust the currentTabGroupNumber and currentCharacterNumber if necessary
  if (self.currentTabGroupNumber == 1 and self.currentCharacterNumber == 0) then
    -- Ignore the maximum width, the output must be at least one character per row
    self.currentCharacterPosition = 1

  elseif (_splitAtWhitespace) then

    local numberOfTabGroups = #self.remainingTabGroups
    local lastTabGroup = self.remainingTabGroups[numberOfTabGroups]
    if (self.currentTabGroupNumber < numberOfTabGroups or self.currentCharacterNumber < #lastTabGroup) then
      self:splitCurrentRowAtLastWhiteSpace()
    end

  end

  -- Extract the pixel group string
  local rowString = ""
  for i = 1, self.currentTabGroupNumber - 1, 1 do
    rowString = rowString .. self.remainingTabGroups[i] .. "\t"
  end

  if (self.currentCharacterNumber > 0) then
    rowString = rowString .. self.remainingTabGroups[self.currentTabGroupNumber]:sub(1, self.currentCharacterNumber)
  end

  -- Remove trailing whitespace and trailing tabs
  rowString = rowString:gsub("[ \t]*$", "")

  return rowString

end

---
-- Sets the currentTabGroupNumber and currentCharacterNumber attributes to the last usable whitespace position if possible.
--
function ClientOutputStringSplitter:splitCurrentRowAtLastWhiteSpace()

  local stringEndPosition = {
    ["tabGroupNumber"] = self.currentTabGroupNumber,
    ["characterNumber"] = self.currentCharacterNumber
  }

  local whitespacePosition
  for i = #self.whitespacePositions, 1, -1 do

    if (self.whitespacePositions[i]["tabGroupNumber"] == stringEndPosition["tabGroupNumber"] and
        self.whitespacePositions[i]["characterNumber"] == stringEndPosition["characterNumber"]
    ) then

      if (stringEndPosition["characterNumber"] > 1) then
        stringEndPosition["characterNumber"] = stringEndPosition["characterNumber"] - 1
      else
        stringEndPosition["tabGroupNumber"] = stringEndPosition["tabGroupNumber"] - 1
        stringEndPosition["characterNumber"] = #self.tabGroups[stringEndPosition["tabGroupNumber"]]
      end

    else
      whitespacePosition = self.whitespacePositions[i]
      break
    end

  end

  if (whitespacePosition ~= nil) then

    if (whitespacePosition["tabGroupNumber"] > 1 or whitespacePosition["characterNumber"] > 0) then
      self.currentTabGroupNumber = whitespacePosition["tabGroupNumber"]
      self.currentCharacterNumber = whitespacePosition["characterNumber"]
    end

  end

end

---
-- Removes the current pixel group from the list of remaining tab groups.
-- The result is saved in the remainingTabGroups attribute.
--
function ClientOutputStringSplitter:removeCurrentPixelGroupFromRemainingTabGroups()

  -- Adjust the last string part
  if (self.currentCharacterNumber > 0) then

    local tabGroup = self.remainingTabGroups[self.currentTabGroupNumber]:sub(self.currentCharacterNumber + 1)

    if (#tabGroup == 0) then
      self.currentTabGroupNumber = self.currentTabGroupNumber + 1
    else
      self.remainingTabGroups[self.currentTabGroupNumber] = tabGroup:gsub("^ *", "")
    end

  end

  -- Adjust the list of remaining tab groups
  if (self.currentTabGroupNumber > 1) then
    self.remainingTabGroups = TableUtils:slice(self.remainingTabGroups, self.currentTabGroupNumber)
  end

end


return ClientOutputStringSplitter
