---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Toggles between all gema maps rot and regular maps rot.
--
-- @type MapRotSwitcher
--
local MapRotSwitcher = {};


---
-- Sets the maprot to _mapRotFilePath.
--
-- @tparam string _mapRotFilePath The path to the maprot file relative from the server root directory
--
function MapRotSwitcher:switchMapRot(_mapRotFilePath)
  setmaprot(_mapRotFilePath);
end

--
-- Sets the maprot to maprot_gema.cfg.
--
function MapRotSwitcher:switchToGemaMapRot()
  self:switchMapRot("config/maprot_gema.cfg");
end

--
-- Sets the maprot to maprot.cfg.
--
function MapRotSwitcher:switchToRegularMapRot()
  self:switchMapRot("config/maprot.cfg");
end


return MapRotSwitcher;
