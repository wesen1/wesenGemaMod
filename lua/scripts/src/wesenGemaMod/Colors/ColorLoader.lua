---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

--
-- Handles loading of the color configuration.
--
ColorLoader = {};

-- Name of the lua configuration file for colors
ColorLoader.colorConfigFile = "colors";

--
-- ColorLoader constructor.
--
-- @param String _colorConfigFile  Name of the lua configuration file for colors
--
function ColorLoader:__construct(_colorConfigFile)

  local instance = {};
  setmetatable(instance, {__index = ColorLoader});

  instance.colorConfigFile = _colorConfigFile;
  
  return instance;

end


--
-- Returns the name of the lua configuration file for colors.
--
-- @return String Name of the lua configuration file for colors
--
function ColorLoader:getColorConfigFile()

  return self.colorConfigFile;
  
end

--
-- Sets the name of the lua configuration file for colors.
--
-- @param String _colorConfigFile Name of the lua configuration file for colors
--
function ColorLoader:setColorConfigFile(_colorConfigFile)

  self.colorConfigFile = _colorConfigFile;
  
end


--
-- Loads a color from the color config file.
--
-- @param String _colorId  Name of the color
--
function ColorLoader:getColor(_colorId)

  return "\f" .. cfg.getvalue(self.colorConfigFile, _colorId);

end

