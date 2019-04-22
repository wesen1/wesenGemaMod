---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Calculates the next tab stop for a specific text pixel position.
--
-- @type TabStopCalculator
--
local TabStopCalculator = setmetatable({}, {});


---
-- The width of one tab in pixels
--
-- @tfield int tabWidth
--
TabStopCalculator.tabWidth = nil;


---
-- TabStopCalculator constructor.
--
-- @tparam int _tabWidth The width of one tab in pixels
--
-- @treturn TabStopCalculator The TabStopCalculator instance
--
function TabStopCalculator:__construct(_tabWidth)

  local instance = setmetatable({}, {__index = TabStopCalculator});

  instance.tabWidth = _tabWidth;

  return instance;

end

getmetatable(TabStopCalculator).__call = TabStopCalculator.__construct;


-- Public Methods

---
-- Returns the pixel position of the last passed tab stop at a specific text pixel position.
--
-- @tparam int _textPixelPosition The pixel position inside the output text
--
-- @treturn int The pixel position of the last passed tab stop relative to the text pixel position
--
function TabStopCalculator:getLastPassedTabStopPosition(_textPixelPosition)

  local lastPassedTabStopPosition;
  if (_textPixelPosition % self.tabWidth == 0) then
    lastPassedTabStopPosition = _textPixelPosition;
  else
    lastPassedTabStopPosition = self:getNumberOfPassedTabStops(_textPixelPosition) * self.tabWidth;
  end

  return lastPassedTabStopPosition;

end

---
-- Returns the number of passed tab stops at a specific text pixel position.
--
-- @tparam int _textPixelPosition The pixel position inside the output text
--
-- @treturn int The number of passed tab stops
--
function TabStopCalculator:getNumberOfPassedTabStops(_textPixelPosition)
  return self:getLastPassedTabStopPosition(_textPixelPosition) / self.tabWidth
end

---
-- Returns the next tab stop position for a specific text pixel position.
--
-- @tparam int _textPixelPosition The pixel position inside the output text
--
-- @treturn int The next tab stop position in pixels
--
function TabStopCalculator:getNextTabStopPosition(_textPixelPosition)

  local nextTabStopPosition;
  if (_textPixelPosition > 0 and _textPixelPosition % self.tabWidth == 0) then
    nextTabStopPosition = _textPixelPosition;
  else
    nextTabStopPosition = self:getLastPassedTabStopPosition(_textPixelPosition) + self.tabWidth;
  end

  return nextTabStopPosition;

end

---
-- Returns the number of the tab stop that follows a specific text pixel position.
--
-- @tparam int _textPixelPosition The pixel position inside the output text
--
-- @treturn int The next tab stop number
--
function TabStopCalculator:getNextTabStopNumber(_textPixelPosition)
  return self:getNextTabStopPosition(_textPixelPosition) / self.tabWidth
end

---
-- Returns the number of tabs that are required to reach a tab stop from a specific text pixel position.
--
-- @tparam int _textPixelPosition The pixel position inside the output text
-- @tparam int _targetTabStopPosition The position of the target tab stop
--
-- @treturn int The number of tabs that are required to reach that tab stop
--
function TabStopCalculator:getNumberOfTabsToTabStop(_textPixelPosition, _targetTabStopPosition)

  local targetTabStopPosition = _targetTabStopPosition;
  if (targetTabStopPosition % self.tabWidth ~= 0) then
    targetTabStopPosition = self:getNextTabStopPosition(targetTabStopPosition);
  end

  local nextTabStopPosition = self:getNextTabStopPosition(_textPixelPosition);
  local numberOfTabsToTabStop = ((targetTabStopPosition - nextTabStopPosition) / self.tabWidth) + 1;

  if (numberOfTabsToTabStop < 0) then
    numberOfTabsToTabStop = 0;
  end

  return numberOfTabsToTabStop;

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


-- Private Methods

---
-- Returns the number of tab stops that are positioned left from a specific text pixel position.
--
-- @tparam int _textPixelPosition The pixel position inside the text
--
-- @treturn int The number of passed tab stops
--
function TabStopCalculator:getNumberOfPassedTabStops(_textPixelPosition)
  return math.floor(_textPixelPosition/self.tabWidth);
end


return TabStopCalculator;
