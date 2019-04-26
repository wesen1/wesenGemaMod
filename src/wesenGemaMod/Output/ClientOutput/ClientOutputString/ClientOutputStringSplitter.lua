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
-- The parent ClientOutputString that will be split by this ClientOutputStringSplitter
--
-- @tfield ClientOutputString parentClientOutputString
--
ClientOutputStringSplitter.parentClientOutputString = nil


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
-- The line split character positions
-- This is needed to split the string at the last possible line split character position
--
-- The table is in the format { { [tabGroupNumber] = int, [characterNumber] = int }, ... }
--
-- @tfield table[] whitespacePositions
--
ClientOutputStringSplitter.lineSplitCharacterPositions = nil

---
-- The current tab group number
--
-- @tfield int currentTabGroupNumber
--
ClientOutputStringSplitter.currentTabGroupNumber = nil

---
-- The current character position inside the current tab group
--
-- @tfield int currentCharacterNumber
--
ClientOutputStringSplitter.currentCharacterNumber = nil


---
-- ClientOutputStringSplitter constructor.
--
-- @tparam ClientOutputString _parentClientOutputString The parent ClientOutputString
--
-- @treturn ClientOutputStringSplitter The ClientOutputStringSplitter instance
--
function ClientOutputStringSplitter:__construct(_parentClientOutputString)

  local instance = setmetatable({}, {__index = ClientOutputStringSplitter})
  instance.parentClientOutputString = _parentClientOutputString

  return instance

end

getmetatable(ClientOutputStringSplitter).__call = ClientOutputStringSplitter.__construct


-- Public Methods

---
-- Splits the parent ClientOutputString into rows based on the ClientOutputString's configuration.
--
-- @tparam bool _returnAsClientOutputStrings Whether to return the rows as ClientOutputString instances
--
-- @treturn string[]|ClientOutputString[] The rows
--
function ClientOutputStringSplitter:splitStringIntoRows(_returnAsClientOutputStrings)

  local ClientOutputFactory = require("Output/ClientOutput/ClientOutputFactory")

  self.remainingTabGroups = self.parentClientOutputString:splitIntoTabGroups()
  self.currentColorString = ""

  local newLineIndent = self.parentClientOutputString:getNewLineIndent()

  local rowStrings = {}
  local isFirstRow = true
  while (#self.remainingTabGroups > 0) do

    local rowString = self.currentColorString

    if (isFirstRow) then
      isFirstRow = false
    else
      rowString = newLineIndent .. rowString
    end

    self.lineSplitCharacterPositions = {}
    self:calculateNextRowEndPosition()

    -- Fetch the next row string
    rowString = rowString .. self:getNextRowString()
    if (_returnAsClientOutputStrings) then
      rowString = ClientOutputFactory.getInstance():getClientOutputString(rowString)
      rowString:setCachedWidth(self.currentRowWidth)
    end

    table.insert(rowStrings, rowString)

    -- Remove the row string from the remaining tab groups
    self:removeCurrentRowFromRemainingTabGroups()

  end

  return rowStrings

end


-- Private Methods

---
-- Calculates the maximum end position of the next row and saves the result in the attributes
-- currentTabGroupNumber and currentCharacterNumber.
--
function ClientOutputStringSplitter:calculateNextRowEndPosition()

  local maximumLineWidth = self.parentClientOutputString:getMaximumLineWidth()
  local lineSplitCharacters = self.parentClientOutputString:getLineSplitCharacters()
  local symbolWidthLoader = self.parentClientOutputString:getSymbolWidthLoader()
  local tabStopCalculator = self.parentClientOutputString:getTabStopCalculator()

  self.currentRowWidth = 0
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

          -- Get the width of the current character
          local currentCharacterWidth = symbolWidthLoader:getCharacterWidth(character)

          -- Check if the new total width exceeds the maximum allowed width
          if (self.currentRowWidth + currentCharacterWidth > maximumLineWidth) then
            return
          else

            if (character:match(lineSplitCharacters)) then
              table.insert(
                self.lineSplitCharacterPositions, {
                  tabGroupNumber = self.currentTabGroupNumber,
                  characterNumber = self.currentCharacterNumber,
                  lineWidthAtPosition = self.currentRowWidth,
                  isWhiteSpace = (character == " ")
              })
            end

            self.currentCharacterNumber = self.currentCharacterNumber + 1
            self.currentRowWidth = self.currentRowWidth + currentCharacterWidth

          end

        end

      end

    end

    -- Jump to the next tab stop
    self.currentRowWidth = tabStopCalculator:getNextTabStopPosition(self.currentRowWidth)

  end

end

---
-- Returns the next row string.
-- Uses the currentTabGroupNumber and currentCharacterNumber attributes to extract the string.
--
-- @treturn string The next pixel group string
--
function ClientOutputStringSplitter:getNextRowString()

  -- Adjust the currentTabGroupNumber and currentCharacterNumber if necessary
  if (self.currentTabGroupNumber == 1 and self.currentCharacterNumber == 0 or
      #self.lineSplitCharacterPositions == 0) then
    -- Ignore the maximum width and line split characters, the output must be at least one character per row
    self.currentCharacterPosition = 1
  end

  -- Find the last availabe line split character
  local numberOfTabGroups = #self.remainingTabGroups
  local lastTabGroup = self.remainingTabGroups[numberOfTabGroups]
  if (self.currentTabGroupNumber < numberOfTabGroups or self.currentCharacterNumber < #lastTabGroup) then
    self:splitCurrentRowAtLastLineSplitCharacter()
  end

  -- Extract the row string
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
-- Sets the currentTabGroupNumber and currentCharacterNumber attributes to the last usable line
-- split character position if possible.
--
function ClientOutputStringSplitter:splitCurrentRowAtLastLineSplitCharacter()

  local stringEndPosition = {
    ["tabGroupNumber"] = self.currentTabGroupNumber,
    ["characterNumber"] = self.currentCharacterNumber
  }

  local lineSplitCharacterPosition
  for i = #self.lineSplitCharacterPositions, 1, -1 do

    if (self.lineSplitCharacterPositions[i]["isWhiteSpace"] and
        self.lineSplitCharacterPositions[i]["tabGroupNumber"] == stringEndPosition["tabGroupNumber"] and
        self.lineSplitCharacterPositions[i]["characterNumber"] == stringEndPosition["characterNumber"]
    ) then

      if (stringEndPosition["characterNumber"] > 1) then
        stringEndPosition["characterNumber"] = stringEndPosition["characterNumber"] - 1
      else
        stringEndPosition["tabGroupNumber"] = stringEndPosition["tabGroupNumber"] - 1
        stringEndPosition["characterNumber"] = #self.tabGroups[stringEndPosition["tabGroupNumber"]]
      end

    else
      lineSplitCharacterPosition = self.lineSplitCharacterPositions[i]
      break
    end

  end

  if (lineSplitCharacterPosition ~= nil) then

    -- Check that the line split character is not the first character of the string
    if (lineSplitCharacterPosition["tabGroupNumber"] > 1 or
        lineSplitCharacterPosition["characterNumber"] > 0
    ) then
      self.currentTabGroupNumber = lineSplitCharacterPosition["tabGroupNumber"]
      self.currentCharacterNumber = lineSplitCharacterPosition["characterNumber"]
      self.currentRowWidth = lineSplitCharacterPosition["lineWidthAtPosition"]
    end

  end

end

---
-- Removes the current row from the list of remaining tab groups.
-- The result is saved in the remainingTabGroups attribute.
--
function ClientOutputStringSplitter:removeCurrentRowFromRemainingTabGroups()

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
