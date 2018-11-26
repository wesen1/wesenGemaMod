---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Stores the start and end position of a tag inside a string.
--
-- @type TagPosition
--
local TagPosition =setmetatable({}, {});


---
-- The start position of a tag inside a string
--
-- @tfield int startPosition
--
TagPosition.startPosition = nil;

---
-- The end position of a tag inside a string
--
-- @tfield int endPosition
--
TagPosition.endPosition = nil;


---
-- TagPosition constructor.
--
-- @tparam int _startPosition The start position
-- @tparam int _endPosition The end position
--
-- @treturn TagPosition The TagPosition instance
--
function TagPosition:__construct(_startPosition, _endPosition)

  local instance = setmetatable({}, {__index = TagPosition});

  instance.startPosition = _startPosition;
  instance.endPosition = _endPosition;

  return instance;

end

getmetatable(TagPosition).__call = TagPosition.__construct;


-- Getters and Setters

---
-- Returns the start position.
--
-- @treturn int The start position
--
function TagPosition:getStartPosition()
  return self.startPosition;
end

---
-- Returns the end position.
--
-- @treturn int The end position
--
function TagPosition:getEndPosition()
  return self.endPosition;
end


-- Public Methods

---
-- Returns whether this tag positions start position is smaller than another tag positions start position.
--
-- @tparam TagPosition _tagPosition The other tag position
--
-- @treturn bool True if this tag position is smaller than the other tag position, false otherwise
--
function TagPosition:isSmallerThan(_tagPosition)

  if (self.startPosition < _tagPosition:getStartPosition()) then
    return true;
  else
    return false;
  end

end


return TagPosition;
