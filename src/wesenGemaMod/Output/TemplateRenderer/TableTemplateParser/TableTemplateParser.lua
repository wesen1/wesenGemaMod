---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local RootTag = require("Output/TemplateRenderer/TableTemplateParser/Tags/RootTag");
local TagFinder = require("Output/TemplateRenderer/TableTemplateParser/TagFinder");

---
-- Parses table templates and returns a generated table.
--
-- @type TableTemplateParser
--
local TableTemplateParser = setmetatable({}, {});


---
-- TableTemplateParser constructor.
--
-- @treturn TableTemplateParser The TableTemplateParser instance
--
function TableTemplateParser:__construct()

  local instance = setmetatable({}, {__index = TableTemplateParser});

  instance.tagFinder = TagFinder();

  return instance;

end

getmetatable(TableTemplateParser).__call = TableTemplateParser.__construct;


-- Public Methods

---
-- Generates a table from a rendered text template.
--
-- @tparam string _renderedTemplateString The renderd template string
--
-- @treturn table The generated table
--
function TableTemplateParser:parseRenderedTemplate(_renderedTemplateString)

  local rootTag = RootTag();
  local currentTag = rootTag;

  local currentStringPosition = 1;
  local totalStringLength = #_renderedTemplateString;

  while (currentStringPosition < totalStringLength) do

    self.tagFinder:findNextTag(_renderedTemplateString, currentStringPosition);

    local nextTag = self.tagFinder:getClosestTagInstance();
    local nextTagPosition = self.tagFinder:getClosestTagPosition();

    currentTag = self:addInnerTextToCurrentTag(currentTag, currentStringPosition, nextTagPosition, _renderedTemplateString);
    currentStringPosition = self:getNewStringPosition(nextTagPosition, totalStringLength);

    if (nextTag) then

      local nextTagParentTag = nextTag:closeCorrespondingTags(currentTag);
      local nextTagInstance = nextTag:getTagOpenInstance();

      nextTagParentTag:addInnerTag(nextTagInstance);
      currentTag = nextTagInstance;

    end

  end

  return rootTag:generateTable();

end

---
-- Adds the inner text until the next tag to the current tag.
-- Also returns the new position in the text.
--
-- @tparam BaseTag _currentTag The current tag
-- @tparam int _currentStringPosition The current position inside the parsed string
-- @tparam TagPosition|bool _nextTagPosition The position of the next tag or false if there is no next tag
-- @tparam string _text The text from which the inner text will be extracted
--
-- @treturn BaseTag The tag to which the inner text was added
--
function TableTemplateParser:addInnerTextToCurrentTag(_currentTag, _currentStringPosition, _nextTagPosition, _text)

  -- Find the end position for the inner text of the current tag
  local innerTextEndPosition;
  if (_nextTagPosition) then
    innerTextEndPosition = _nextTagPosition:getStartPosition() - 1;
  else
    innerTextEndPosition = nil;
  end

  return _currentTag:addInnerText(_text:sub(_currentStringPosition, innerTextEndPosition));

end

---
-- Returns the new position inside the parsed string.
--
-- @tparam TagPosition|bool _nextTagPosition The next tag position or false if there is no next tag
-- @tparam int _totalTextLength The total text length
--
function TableTemplateParser:getNewStringPosition(_nextTagPosition, _totalTextLength)

  if (_nextTagPosition) then
    return _nextTagPosition:getEndPosition() + 1;
  else
    return _totalTextLength;
  end

end


return TableTemplateParser;
