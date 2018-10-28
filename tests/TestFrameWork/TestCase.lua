---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local luaunit = require("TestFrameWork/LuaUnitCustom");
local mach = require("mach");

---
-- Parent class for all unit tests.
--
local TestCase = setmetatable({}, { __index = luaunit });


---
-- The list of mocked dependencies
-- This list is in the format { "dependencyPackageId" => originalValue }
--
-- @tfield table mockedDependencies
--
TestCase.mockedDependencies = nil;

---
-- The list of classes that received the mocked dependencies
--
-- @tfield string[] mockReceivingClasses
--
TestCase.mockReceivingClasses = nil;


-- Public Methods

---
-- Method that is called before a test is executed.
--
function TestCase:setUp()

  -- Initialize the lists of mocked dependencies and mock receiving classes
  self.mockedDependencies = {};
  self.mockReceivingClasses = {};

end

---
-- Method that is called after a test was executed.
--
function TestCase:tearDown()

  -- Restore the original dependencies
  for loadedPackagesId, originalDependency in pairs(self.mockedDependencies) do
    package.loaded[loadedPackagesId] = originalDependency;
  end

  -- Reload the classes into which the mocked dependencies were injected
  for _, classPath in ipairs(self.mockReceivingClasses) do
    package.loaded[classPath] = nil;
    require(classPath);
  end

  -- @todo: Replace cached local variable contents with new require call

end


-- Protected Methods

---
-- Returns the mock for a object or class.
--
-- @tparam table _object The object or class
-- @tparam string _mockName The name of the mock
--
-- @treturn table The mock of the object or class
--
function TestCase:getMock(_object, _mockName)
  return mach.mock_object(_object, _mockName);
end

---
-- Returns the mock for a dependency (a class that is included by using "require").
-- The class for which the dependency mock is used must be required after this method was called.
--
-- @tparam string _mockClassPath The class path for the mocked dependency
-- @tparam string _mockReceivingClassPath The path to the class into which the dependency mock will be injected
-- @tparam string _mockName The name of the mock
--
-- @treturn table The dependency mock
--
function TestCase:getDependencyMock(_mockClassPath, _mockReceivingClassPath, _mockName)

  -- Backup the original package.loaded value of the dependency
  self.mockedDependencies[_mockClassPath] = package.loaded[_mockClassPath];
  table.insert(self.mockReceivingClasses, _mockReceivingClassPath);

  -- Get the class
  local class = package.loaded[_mockClassPath];
  if (not class) then
    class = require(_mockClassPath);
  end

  local dependencyMock = self:getMock(class, _mockName);

  -- Replace the dependency by the mock
  package.loaded[_mockClassPath] = dependencyMock;

  -- Unload the mock receiving class to inject the depenceny mock on next load
  package.loaded[_mockReceivingClassPath] = nil;

  return dependencyMock;

end


return TestCase;
