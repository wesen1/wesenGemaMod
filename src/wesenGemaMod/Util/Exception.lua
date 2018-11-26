---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Error exception for the error() and pcall() functions.
--
-- @type Exception
--
local Exception = setmetatable({}, {});


---
-- The exception message
--
-- @tfield string|TextTemplate message
--
Exception.message = nil;


---
-- Exception constructor.
--
-- @tparam string|TextTemplate _message The exception message
--
function Exception:__construct(_message)

  local instance = setmetatable({}, {__index = Exception});

  instance.message = _message;

  return instance;

end

getmetatable(Exception).__call = Exception.__construct;


-- Getters and Setters

---
-- Returns the message.
--
-- @treturn string|TextTemplate The message
--
function Exception:getMessage()
  return self.message;
end


return Exception;
