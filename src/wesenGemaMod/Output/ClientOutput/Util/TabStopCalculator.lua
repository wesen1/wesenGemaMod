---
-- @author wesen
-- @copyright 2018-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Provides methods to calculate tab stop positions and distances to tab stops.
--
-- @type TabStopCalculator
--
local TabStopCalculator = setmetatable({}, {})


---
-- The width of one tab in pixels
--
-- @tfield int tabWidth
--
TabStopCalculator.tabWidth = nil


---
-- TabStopCalculator constructor.
--
-- @tparam int _tabWidth The width of one tab in pixels
--
-- @treturn TabStopCalculator The TabStopCalculator instance
--
function TabStopCalculator:__construct(_tabWidth)

  local instance = setmetatable({}, {__index = TabStopCalculator})
  instance.tabWidth = _tabWidth

  return instance

end

getmetatable(TabStopCalculator).__call = TabStopCalculator.__construct


-- Public Methods

---
-- Returns the number of passed tab stops at a specific text pixel position.
--
-- @tparam int _textPixelPosition The pixel position inside the output text
--
-- @treturn int The number of passed tab stops
--
function TabStopCalculator:getNumberOfPassedTabStops(_textPixelPosition)
  return math.floor(_textPixelPosition / self.tabWidth)
end

---
-- Returns the number of the tab stop that follows a specific text pixel position.
--
-- @tparam int _textPixelPosition The pixel position inside the output text
--
-- @treturn int The next tab stop number
--
function TabStopCalculator:getNextTabStopNumber(_textPixelPosition)

  local numberOfPassedTabStops = self:getNumberOfPassedTabStops(_textPixelPosition)
  if (_textPixelPosition > 0 and _textPixelPosition % self.tabWidth == 0) then
    return numberOfPassedTabStops
  else
    return numberOfPassedTabStops + 1
  end

end

---
-- Returns the next tab stop position for a specific text pixel position.
--
-- @tparam int _textPixelPosition The pixel position inside the output text
--
-- @treturn int The next tab stop position in pixels
--
function TabStopCalculator:getNextTabStopPosition(_textPixelPosition)
  return self:getNextTabStopNumber(_textPixelPosition) * self.tabWidth
end

---
-- Converts a tab number to a pixel position.
--
-- @tparam int _tabNumber The tab number
--
-- @treturn int The corresponding pixel position
--
function TabStopCalculator:convertTabNumberToPosition(_tabNumber)
  return _tabNumber * self.tabWidth
end


return TabStopCalculator
