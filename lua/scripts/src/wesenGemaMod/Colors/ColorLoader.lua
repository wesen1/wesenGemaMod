---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- 

---
-- Handles loading of the color configuration.
--
local ColorLoader = {};


---
-- The name of the lua configuration file for colors
--
ColorLoader.colorConfigFileName = "colors";


---
-- ColorLoader constructor.
--
-- @param String _colorConfigFileName The name of the lua configuration file for colors
--
function ColorLoader:__construct(_colorConfigFileName)

  local instance = {};
  setmetatable(instance, {__index = ColorLoader});

  instance.colorConfigFileName = _colorConfigFileName;
  
  return instance;

end


---
-- Loads a color from the color config file.
--
-- @param String _colorId Name of the color
-- 
-- @return String The color with leading \f
--
function ColorLoader:getColor(_colorId)

  return "\f" .. cfg.getvalue(self.colorConfigFileName, _colorId);

end


return ColorLoader;
