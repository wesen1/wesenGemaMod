---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Stores a string id of a static string and provides methods to fetch the static string from the config file.
--
-- @type StaticString
--
local StaticString = setmetatable({}, {})


---
-- The id of the static string in the Strings.cfg file
--
-- @tfield string stringId
--
StaticString.stringId = nil


---
-- StaticString constructor.
--
-- @tparam string _stringId The id of the static string in the Strings.cfg file
--
-- @treturn StaticString The StaticString instance
--
function StaticString:__construct(_stringId)
  local instance = setmetatable({}, {__index = StaticString})
  instance.stringId = _stringId

  return instance
end

getmetatable(StaticString).__call = StaticString.__construct


---
-- Converts the static string object to the static string to which it points.
--
-- @treturn string The static string
--
function StaticString:__tostring()
  return self:getString()
end


-- Public Methods

---
-- Returns the static string with the static string id of this static string object.
--
-- @treturn string The static string
--
function StaticString:getString()

  local staticString = cfg.getvalue("templates/Strings", self.stringId)

  -- Discard the first and last symbol in the string (which are the '"' delimiters)
  return staticString:sub(2, -2)
end


return StaticString
