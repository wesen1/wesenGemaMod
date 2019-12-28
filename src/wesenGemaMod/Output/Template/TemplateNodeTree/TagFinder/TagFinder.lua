---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TemplateTag = require("Output/Template/TemplateNodeTree/TagFinder/TemplateTag")

---
-- Searches rendered table templates for tags and provides methods to get the next tags.
--
-- @type TagFinder
--
local TagFinder = setmetatable({}, {})


---
-- The list of tag patterns in the format { ["tagName"] = "tagPattern" }
--
-- @tfield string[] tagPatterns
--
TagFinder.tagPatterns = {
  ["config"] = "##+%[ *CONFIG *]#*;",
  ["end-config"] = "##+%[ *ENDCONFIG *]#*;",
  ["custom-field"] = "%-%-+%[ *FIELD *]%-*;",
  ["custom-field-end"] = "%-%-+%[ *ENDFIELD *]%-*;",
  ["row"] = "__+;",
  ["row-field"] = "%-%-+;"
}


-- Cache

---
-- The cached template tags that were found before they were the closest tag
-- This list is in the format { ["tagName"] = TemplateTag, ... }
--
-- @tfield TemplateTag[] nextTags
--
TagFinder.nextTags = nil

---
-- The last string that was searched by this TagFinder
-- This is used to check whether the TagFinder can use the cached next tags
--
-- @tfield string lastSearchText
--
TagFinder.lastSearchText = nil


---
-- TagFinder constructor.
--
-- @treturn TagFinder The TagFinder instance
--
function TagFinder:__construct()
  local instance = setmetatable({}, {__index = TagFinder})
  instance.nextTags = {}

  return instance
end

getmetatable(TagFinder).__call = TagFinder.__construct


-- Public Methods

---
-- Finds and returns the next tag.
--
-- @tparam string _text The text to search for tags
-- @tparam int _textPosition The start position inside the text to start the search at
--
-- @treturn TemplateTag|nil The next tag or nil if no tag was found
--
function TagFinder:findNextTag(_text, _textPosition)

  local nextTemplateTag
  for tagName, tagPattern in pairs(self.tagPatterns) do

    local templateTag = self:getNextTagPosition(_text, _textPosition, tagName, tagPattern)
    if (templateTag ~= false and
        (nextTemplateTag == nil or templateTag:getStartPosition() < nextTemplateTag:getStartPosition())
    ) then
      nextTemplateTag = templateTag
    end

  end

  if (nextTemplateTag ~= nil) then
    -- Remove the cached next tag position of the current closest tag
    self.nextTags[nextTemplateTag:getName()] = nil
  end

  return nextTemplateTag

end


-- Private Methods

---
-- Returns the position of the next tag inside the text.
--
-- @tparam string _text The text
-- @tparam int _textPosition The start position inside the text
-- @tparam string _tagName The name of the tag to search the text for
-- @tparam string _tagPattern The tag pattern for the tag name
--
-- @treturn TemplateTag|bool The next tag or false if there are no more tags of this tag type inside the text
--
function TagFinder:getNextTagPosition(_text, _textPosition, _tagName, _tagPattern)

  local nextTemplateTag = self:getCachedTagPosition(_text, _textPosition, _tagName)
  if (nextTemplateTag == nil) then

    -- Search for the start position of the next tag with the pattern
    local nextTagStartPosition, nextTagEndPosition = _text:find(_tagPattern, _textPosition)
    if (nextTagStartPosition == nil) then
      nextTemplateTag = false
    else
      nextTemplateTag = TemplateTag(_tagName, nextTagStartPosition, nextTagEndPosition)
    end

    -- Cache the tag
    self.nextTags[_tagName] = nextTemplateTag

  end

  return nextTemplateTag

end

---
-- Returns the cached tag position for a specific tag and clears the cache if necessary.
-- Will return false if there is no next occurrence of the specific tag type.
--
-- @tparam string _text The text that was searched for tags
-- @tparam int _textPosition The start position inside the text
-- @tparam string _tagName The tag name that the text was searched for
--
-- @treturn TemplateTag|bool|nil The cached tag or nil if there is no cached next tag
--
function TagFinder:getCachedTagPosition(_text, _textPosition, _tagName)

  if (_text == self.lastSearchText) then

    local cachedTemplateTag = self.nextTags[_tagName]
    if (cachedTemplateTag == false or
        (cachedTemplateTag ~= nil and cachedTemplateTag:getStartPosition() > _textPosition)
    ) then
      return cachedTemplateTag
    else
      self.nextTags[_tagName] = nil
    end

  else
    -- The last search text differs from the current search text
    -- Therefore all previous cached values must be cleared as they do not reference the same search
    self.lastSearchText = _text
    self.nextTags = {}
  end

end


return TagFinder
