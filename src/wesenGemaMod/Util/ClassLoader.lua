---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local lfs = require("lfs");
local TableUtils = require("Util/TableUtils")

---
-- Provides static methods to load classes from a specific directory.
--
-- @type ClassLoader
--
local ClassLoader = {}


---
-- Returns a list of classes from a specific directory.
--
-- @tparam string _path The directory path
-- @tparam string _fileNameExpression The expression that the file names must match
-- @tparam string[] _excludedClassNames The list of class names that shall not be loaded when found
--
-- @treturn table[] The list of classes
--
function ClassLoader.loadClasses(_path, _fileNameExpression, _excludedClassNames)

  local classes = {}

  local excludedClassNames = _excludedClassNames
  if (excludedClassNames == nil) then
    excludedClassNames = {}
  end

  -- Iterate over each file in the directory
  for fileName in lfs.dir(_path) do

    if (fileName:match(_fileNameExpression)) then

      local className = fileName:gsub(".lua", "")
      if (not TableUtils.tableHasValue(excludedClassNames, className)) then
        table.insert(classes, require(_path .. "/" .. className))
      end

    end

  end

  return classes

end


return ClassLoader
