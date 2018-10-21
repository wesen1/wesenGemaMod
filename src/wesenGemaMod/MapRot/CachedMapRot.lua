---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Represents the currently loaded maprot.
--
-- @type CachedMapRot
--
local CachedMapRot = setmetatable({}, {});


---
-- CachedMapRot constructor.
--
-- @treturn CachedMapRot The CachedMapRot instance
--
function CachedMapRot:__construct()

  local instance = setmetatable({}, { __index = CachedMapRot });

  return instance;

end

getmetatable(CachedMapRot).__call = CachedMapRot.__construct;


-- Public Methods

---
-- Loads the maprot from a specified file path.
-- The path must be relative from the server root directory, e.g. "config/maprot.cfg"
--
-- @tparam string _mapRotFilePath The path to the maprot file relative from the server root directory
--
function CachedMapRot:load(_savedMapRot)
  setmaprot(_savedMapRot:getFilePath());
end

---
-- Returns the next maprot entry.
--
-- @treturn table The next maprot entry
--
function CachedMapRot:getNextEntry()
  return getmaprotnextentry();
end

---
-- Adds a map to the loaded map rot.
--
-- @tparam string _mapName The map name
--
function CachedMapRot:addMap(_mapName)

  local mapRotEntry = {
    ["map"] = _mapName,
    ["mode"] = GM_CTF,
    ["time"] = 15,
    ["allowVote"] = 1,
    ["minplayer"] = 0,
    ["maxplayer"] = 16,
    ["skiplines"] = 0
  };

  local mapRot = getwholemaprot();
  table.insert(mapRot, mapRotEntry);
  setwholemaprot(mapRot);

end

---
-- Removes a map from the loaded map rot.
--
-- @tparam string _mapName The map name
--
function CachedMapRot:removeMap(_mapName)

  local mapRot = getwholemaprot();
  local updatedMapRot = {};

  for _, mapRotEntry in pairs(mapRot) do
    if (mapRotEntry["map"] ~= _mapName) then
      table.insert(updatedMapRot, mapRotEntry);
    end
  end

  setwholemaprot(updatedMapRot);

end

---
-- Clears the cached map rot.
--
function CachedMapRot:clear()
  setwholemaprot({});
end


return CachedMapRot;
