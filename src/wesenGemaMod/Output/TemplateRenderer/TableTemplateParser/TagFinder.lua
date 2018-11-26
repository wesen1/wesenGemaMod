---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local CustomFieldTag = require("Output/TemplateRenderer/TableTemplateParser/Tags/CustomFieldTag");
local CustomFieldEndTag = require("Output/TemplateRenderer/TableTemplateParser/Tags/CustomFieldEndTag");
local RowFieldTag = require("Output/TemplateRenderer/TableTemplateParser/Tags/RowFieldTag");
local RowTag = require("Output/TemplateRenderer/TableTemplateParser/Tags/RowTag");
local TagPosition = require("Output/TemplateRenderer/TableTemplateParser/TagPosition");

---
-- Searches rendered table templates for tags.
-- Also provides methods to get the next tag positions.
--
-- @type TagFinder
--
local TagFinder = setmetatable({}, {});


---
-- The list of tag patterns in the format { ["tagType"] = "tagPattern" }
--
-- @tfield string[] tagPatterns
--
TagFinder.tagPatterns = nil;
TagFinder.tagPatterns = {
  ["CustomField"] = "%-%-+%[ *FIELD *]%-*;",
  ["CustomFieldEnd"] = "%-%-+%[ *ENDFIELD *]%-*;",
  ["Row"] = "__+;",
  ["RowField"] = "%-%-+;"
}


-- Last search result

---
-- The type of the closest tag of the last search
--
-- @tfield string closestTagType
--
TagFinder.closestTagType = nil;

---
-- The position of the closest tag of the last search
--
-- @tfield TagPosition closestTagPosition
--
TagFinder.closestTagPosition = nil;


-- Cache

---
-- The cached tag positions
-- This list is in the format { ["tagType"] = TagPosition }
--
-- @tfield TagPosition[] nextTagPositions
--
TagFinder.nextTagPositions = {};

---
-- The last string that was searched by this TagFinder
-- This is used to check whether the TagFinder can use the cached tag positions
--
-- @tfield string lastSearchText
--
TagFinder.lastSearchText = nil;

---
-- The last search offset for the search string with which this TagFinder searched for the next tag
-- This is used to check whether the TagFinder can use the cached tag positions
--
-- @tfield int lastSearchOffset
--
TagFinder.lastSearchOffset = nil;


---
-- TagFinder constructor.
--
-- @treturn TagFinder The TagFinder instance
--
function TagFinder:__construct()

  local instance = setmetatable({}, {__index = TagFinder});

  instance.nextTagPositions = {};

  instance.closestTagType = nil;
  instance.closestTagPosition = nil;

  instance.lastSearchText = nil;
  instance.lastSearchOffset = nil;

  return instance;

end

getmetatable(TagFinder).__call = TagFinder.__construct;


-- Getters and Setters

---
-- Returns an instance of the closest tag type.
--
-- @treturn BaseTag|nil The tag instance or nil if there are no more tags
--
function TagFinder:getClosestTagInstance()

  if (self.closestTagType == "CustomField") then
    return CustomFieldTag();
  elseif (self.closestTagType == "CustomFieldEnd") then
    return CustomFieldEndTag();
  elseif (self.closestTagType == "Row") then
    return RowTag();
  elseif (self.closestTagType == "RowField") then
    return RowFieldTag();
  else
    return nil;
  end

end

---
-- Returns the position of the closest tag.
--
-- @treturn TagPosition The position of the closest tag
--
function TagFinder:getClosestTagPosition()
  return self.closestTagPosition;
end


-- Public Methods

---
-- Finds the next tag and stores the result in the attributes closestTagType, closestTagStartPosition and
-- closestTagEndPosition.
--
-- @tparam string _text The text to search for tags
-- @tparam int _textPosition The start position inside the text to start the search at
--
function TagFinder:findNextTag(_text, _textPosition)

  self.closestTagType = nil;
  self.closestTagPosition = nil;

  local newTagFound = false;
  for tagType, tagPattern in pairs(self.tagPatterns) do

    local nextTagPosition = self:getNextTagPosition(_text, _textPosition, tagType, tagPattern);
    if (nextTagPosition ~= false) then
      newTagFound = true;
    end

    self:updateSavedTagPositions(nextTagPosition, tagType);

  end

  if (newTagFound) then
    -- Remove the cached next tag position of the current closest tag
    self.nextTagPositions[self.closestTagType] = nil;
  else
    self.closestTagType = false;
    self.closestTagPosition = false;
  end

end


-- Private Methods

---
-- Returns the cached tag position for a specific tag and clears the cache if necessary.
-- Will return false if there is no next occurrence of the specific tag type.
--
-- @tparam string _text The text that was searched for tags
-- @tparam int _textPosition The start position inside the text
-- @tparam string _tagType The tag type that the text was searched for
--
-- @treturn TagPosition|bool|nil The cached tag position or nil if there is no cached next tag position
--
function TagFinder:getCachedTagPosition(_text, _textPosition, _tagType)

  if (_text == self.lastSearchText and _textPosition == self.lastSearchOffset) then
    -- Cache can be used
    return self.nextTagPositions[_tagType];

  else
    -- The last search text or the last search offset differ from the current search text or search offset
    -- Therefore all previous cached values must be cleared as they do not reference the same search
    self.lastSearchText = _text;
    self.lastSearchOffset = _textPosition;
    self.nextTagPositions = {};
  end

end

---
-- Returns the position of the next tag inside the text.
--
-- @tparam string _text The text
-- @tparam int _textPosition The start position inside the text
-- @tparam string _tagType The tag type to search the text for
-- @tparam string _tagPattern The tag pattern for the tag type
--
-- @treturn TagPosition|bool The next tag position or false if there are no more tags of this tag type inside the text
--
function TagFinder:getNextTagPosition(_text, _textPosition, _tagType, _tagPattern)

  local nextTagPosition = self:getCachedTagPosition(_text, _textPosition, _tagType);
  if (nextTagPosition == nil) then

    -- Search for the start position of the next tag of the tag type
    local nextTagStartPosition, nextTagEndPosition = _text:find(_tagPattern, _textPosition);
    if (nextTagStartPosition == nil) then
      nextTagPosition = false;
    else
      nextTagPosition = TagPosition(nextTagStartPosition, nextTagEndPosition);
    end
  end

  return nextTagPosition;

end

---
-- Updates the currently closed and the cached tag positions.
--
-- @tparam TagPosition _nextTagPosition The position of the next tag for a specific tag type
-- @tparam string _tagType The type of the next tag
--
function TagFinder:updateSavedTagPositions(_nextTagPosition, _tagType)

  -- Check whether the next tag of this tag type is the new closest tag
  if (_nextTagPosition ~= false) then

    if (not self.closestTagPosition or _nextTagPosition:isSmallerThan(self.closestTagPosition)) then

      -- Add the current closest tag to the cache
      if (self.closestTagPosition) then
        self.nextTagPositions[self.closestTagType] = self.closestTagPosition;
      end

      -- Set the closest tag to the next tag
      self.closestTagType = _tagType;
      self.closestTagPosition = _nextTagPosition;
    end

  else
    -- Add the next tag position to the cache
    self.nextTagPositions[_tagType] = _nextTagPosition;
  end

end


return TagFinder;
