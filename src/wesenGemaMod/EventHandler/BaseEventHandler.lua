---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Parent class for event handlers.
-- Stores a parent gema mode and a output.
-- Each event handler must provide a public method "handleEvent".
--
-- @type BaseEventHandler
--
local BaseEventHandler = setmetatable({}, {});

---
-- The parent gema mod to which this EventHandler belongs
--
-- @tfield GemaMode parentGemaMode
--
BaseEventHandler.parentGemaMode = nil;

---
-- The output
--
-- @tparam Output output
--
BaseEventHandler.output = nil;


---
-- BaseEventHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn BaseEventHandler The BaseEventHandler instance
--
function BaseEventHandler:__construct(_parentGemaMode)

  local instance = setmetatable({}, {__index = BaseEventHandler});

  instance.parentGemaMode = _parentGemaMode;
  instance.output = _parentGemaMode:getOutput();

  return instance;

end

getmetatable(BaseEventHandler).__call = BaseEventHandler.__construct;


return BaseEventHandler;
