---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ObjectUtils = require("Util/ObjectUtils");

---
-- Stores information about a tag inside a table template.
--
-- @type BaseTag
--
local BaseTag = setmetatable({}, {});


---
-- The parent tag of this tag.
-- May be nil if this tag is the root tag.
--
-- @tfield BaseTag parentTag
--
BaseTag.parentTag = nil;

---
-- Stores the strings inside this tag that are not inside sub tags
--
-- @tfield string[] innerTexts
--
BaseTag.innerTexts = {};

---
-- Stores the sub tags of this tag
--
-- @tfield BaseTag[] innerTags
--
BaseTag.innerTags = {};

---
-- Stores the order in which inner texts and tags were added
-- This is used to later reconstruct the table from the inner contents of each tag
-- The values inside this list are either "text" or "tag"
--
-- @tfield string[] innerContents
--
BaseTag.innerContents = {};

---
-- The pattern by which this tag can be found inside a string.
-- This must be set by child classes.
--
-- @tfield string pattern
--
BaseTag.pattern = nil;

---
-- The list of tag types that are closed by this tag
-- This list must be in the order in which the tags are closed (e.g. row fields are closed before the row)
-- A tag can only close up to one tag per close tag type
--
-- @tfield BaseTag[] closeTagTypes
--
BaseTag.closeTagTypes = {};


---
-- BaseTag constructor.
--
-- @tparam BaseTag _parentTag The parent tag (optional)
--
-- @treturn BaseTag The BaseTag instance
--
function BaseTag:__construct(_parentTag)

  local instance = setmetatable({}, {__index = BaseTag});

  if (_parentTag) then
    instance.parentTag = _parentTag;
  end

  instance.innerTexts = {};
  instance.innerTags = {};
  instance.innerContents = {};

  return instance;

end

getmetatable(BaseTag).__call = BaseTag.__construct;


-- Getters and Setters

---
-- Returns the parent tag.
--
-- @treturn BaseTag The parent tag
--
function BaseTag:getParentTag()
  return self.parentTag;
end

---
-- Sets the parent tag.
--
-- @tparam BaseTag _parentTag The parent tag
--
function BaseTag:setParentTag(_parentTag)
  self.parentTag = _parentTag;
end

---
-- Returns the tag instance that will be inserted into the tag tree.
-- This is usally the same tag type as the object that this method was called on.
--
-- @treturn BaseTag The tag instance that will be inserted into the tag tree
--
function BaseTag:getTagOpenInstance()
  return self;
end


-- Public Methods

---
-- Adds an inner text to this tag.
--
-- @tparam string _text The inner text
--
-- @treturn BaseTag The tag to which the inner text was really added
--
function BaseTag:addInnerText(_text)

  table.insert(self.innerTexts, _text);
  table.insert(self.innerContents, "text");

  return self;

end

---
-- Adds an inner tag to this tag.
--
-- @tparam BaseTag _tag The inner tag
--
function BaseTag:addInnerTag(_tag)

  _tag:setParentTag(self);
  table.insert(self.innerTags, _tag);
  table.insert(self.innerContents, "tag");
end

---
-- Closes all parent tags that are closed by this tag type.
-- Also returns the tag to which this tag must then be added.
--
-- @tparam BaseTag _currentTag The current tag in which this tag occurred
--
-- @treturn BaseTag The tag to which this tag must be added
--
function BaseTag:closeCorrespondingTags(_currentTag)

  local currentTag = _currentTag;

  for _, closeTagType in ipairs(self.closeTagTypes) do
    if (ObjectUtils:isInstanceOf(currentTag, closeTagType)) then
      currentTag = currentTag:getParentTag();
    end
  end

  return currentTag;

end

---
-- Generates and returns a table from the inner text and tags.
--
-- @treturn table The generated table
--
function BaseTag:generateTable()

  local innerTextIndex = 1;
  local innerTagIndex = 1;

  local tableRows = {};
  for _, innerContent in ipairs(self.innerContents) do

    if (innerContent == "text") then

      local innerText = self.innerTexts[innerTextIndex];
      if (#innerText > 0) then
        self:addInnerTextToTableRows(tableRows, innerText);
      end

      innerTextIndex = innerTextIndex + 1;

    else
      local innerTag = self.innerTags[innerTagIndex];
      local innerTagTable = innerTag:generateTable();

      if (innerTagTable) then
        self:addInnerTagTableToTableRows(tableRows, innerTagTable);
      end

      innerTagIndex = innerTagIndex + 1;
    end

  end

  return tableRows;

end


-- Protected Methods

---
-- Adds an inner text to the generated table rows.
--
-- @tparam table _tableRows The generated table rows
-- @tparam string _innerText The inner text
--
function BaseTag:addInnerTextToTableRows(_tableRows, _innerText)
end

---
-- Adds an inner tag to the generated table rows.
--
-- @tparam table _tableRows The generated table rows
-- @tparam table _innerTagTable The table that was generated by the inner tag
--
function BaseTag:addInnerTagTableToTableRows(_tableRows, _innerTagTable)
end


return BaseTag;
