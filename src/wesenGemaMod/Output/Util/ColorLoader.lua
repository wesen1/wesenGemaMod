---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Handles loading of the color configuration.
--
-- @type ColorLoader
--
local ColorLoader = setmetatable({}, {});


---
-- The name of the lua configuration file for colors
--
-- @tfield string colorConfigFileName
--
ColorLoader.colorConfigFileName = nil;


---
-- ColorLoader constructor.
--
-- @tparam string _colorConfigFileName The name of the lua configuration file for colors
-- 
-- @treturn ColorLoader The ColorLoader instance
--
function ColorLoader:__construct(_colorConfigFileName)

  local instance = setmetatable({}, {__index = ColorLoader});

  instance.colorConfigFileName = _colorConfigFileName;

  return instance;

end

getmetatable(ColorLoader).__call = ColorLoader.__construct;


-- Class Methods

---
-- Loads a color from the color config file.
--
-- @tparam string _colorId Name of the color
--
-- @treturn string The color with leading "\f"
--
function ColorLoader:loadColor(_colorId)
  return "\f" .. cfg.getvalue(self.colorConfigFileName, _colorId);
end


return ColorLoader;
