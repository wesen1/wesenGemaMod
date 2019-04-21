---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ClassLoader = require("Util/ClassLoader");

---
-- Wrapper class for the event handlers.
--
-- @type EventHandler
--
local EventHandler = setmetatable({}, {});


---
-- The list of event handlers
--
-- @tfield BaseEventHandler[] eventHandlers
--
EventHandler.eventHandlers = nil


-- Metamethods

---
-- EventHandler constructor.
--
-- @treturn EventHandler The EventHandler instance
--
function EventHandler:__construct()

  local instance = setmetatable({}, {__index = EventHandler});
  instance.eventHandlers = {}

  return instance

end

getmetatable(EventHandler).__call = EventHandler.__construct


-- Public Methods

---
-- Loads all event handler classes from a specific directory into this EventHandler.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
-- @tparam string _eventHandlerDirectoryPath The directory path
--
function EventHandler:loadEventHandlers(_parentGemaMode, _eventHandlerDirectoryPath)

  -- Load all files whose names end with "Handler.lua"
  local eventHandlerClasses = ClassLoader.loadClasses(
    _eventHandlerDirectoryPath,
    "^.+Handler.lua$",
    { "BaseEventHandler", "PlayerCallMapVoteHandler" }
  )
  for _, eventHandlerClass in ipairs(eventHandlerClasses) do
    table.insert(self.eventHandlers, eventHandlerClass(_parentGemaMode))
  end

end

---
-- Initializes the event listeners for all event handlers.
--
function EventHandler:initializeEventListeners()

  for eventName, eventHandler in pairs(self:getSupportedEvents()) do

    --
    -- The lua server calls global functions that are named like the corresponding event
    -- when the event occurs.
    --
    -- This loop adds a global function for each event name.
    -- That function calls the event handler and passes all received arguments to its handleEvent method
    --
    _G[eventName] = function(...)
      return eventHandler:handleEvent(...)
    end

  end

end


-- Private Methods

---
-- Returns all events that this EventHandler supports.
-- The list is in the format: { [eventName] = eventHandler }
--
-- @treturn table The list of supported events
--
function EventHandler:getSupportedEvents()

  local supportedEvents = {}
  for _, eventHandler in ipairs(self.eventHandlers) do

    local targetEventName = eventHandler:getTargetEventName()
    supportedEvents[targetEventName] = eventHandler

  end

  return supportedEvents

end


return EventHandler;
