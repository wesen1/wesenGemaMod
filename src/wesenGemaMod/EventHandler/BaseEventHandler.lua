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
-- The name of the event that this event handler handles
--
-- @tparam string targetEventName
--
BaseEventHandler.targetEventName = nil

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
-- @tparam string _targetEventName The name of the event that this event handler handles
--
-- @treturn BaseEventHandler The BaseEventHandler instance
--
function BaseEventHandler:__construct(_parentGemaMode, _targetEventName)

  local instance = setmetatable({}, {__index = BaseEventHandler});

  instance.parentGemaMode = _parentGemaMode;
  instance.targetEventName = _targetEventName

  instance.output = _parentGemaMode:getOutput();

  return instance;

end

getmetatable(BaseEventHandler).__call = BaseEventHandler.__construct;


-- Public Methods

---
-- Returns the name of the event that this event handler handles.
--
-- @treturn string The name of the event that this event handler handles
--
function BaseEventHandler:getTargetEventName()
  return self.targetEventName
end


-- Protected Methods

---
-- Returns the player object for a specific client number.
--
-- @tparam int _cn The client number
--
-- @treturn Player|nil The Player object or nil if no Player object for that client number exists
--
function BaseEventHandler:getPlayerByCn(_cn)
  return self.parentGemaMode:getPlayerList():getPlayer(_cn)
end


return BaseEventHandler
