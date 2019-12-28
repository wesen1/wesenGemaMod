---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Stores information about a template tag inside a rendered template string.
--
-- @type TemplateTag
--
local TemplateTag = setmetatable({}, {})


---
-- The name of the tag
--
-- @tfield string name
--
TemplateTag.name = nil

---
-- The start position of a tag inside a string
--
-- @tfield int startPosition
--
TemplateTag.startPosition = nil

---
-- The end position of a tag inside a string
--
-- @tfield int endPosition
--
TemplateTag.endPosition = nil


---
-- TemplateTag constructor.
--
-- @tparam string _name The tag name
-- @tparam int _startPosition The start position
-- @tparam int _endPosition The end position
--
-- @treturn TemplateTag The TemplateTag instance
--
function TemplateTag:__construct(_name, _startPosition, _endPosition)

  local instance = setmetatable({}, {__index = TemplateTag})

  instance.name = _name
  instance.startPosition = _startPosition
  instance.endPosition = _endPosition

  return instance

end

getmetatable(TemplateTag).__call = TemplateTag.__construct


-- Getters and Setters

---
-- Returns the name of this tag.
--
-- @treturn string The name
--
function TemplateTag:getName()
  return self.name
end

---
-- Returns the start position.
--
-- @treturn int The start position
--
function TemplateTag:getStartPosition()
  return self.startPosition
end

---
-- Returns the end position.
--
-- @treturn int The end position
--
function TemplateTag:getEndPosition()
  return self.endPosition
end


return TemplateTag
