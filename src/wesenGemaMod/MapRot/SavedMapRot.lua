---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Represents a maprot file in the config folder.
--
-- @type SavedMapRot
--
local SavedMapRot = setmetatable({}, {});


---
-- The path to the maprot file
--
-- @tfield string filePath
--
SavedMapRot.filePath = nil;


---
-- SavedMapRot constructor.
--
-- @treturn SavedMapRot The SavedMapRot instance
--
function SavedMapRot:__construct()

  local instance = setmetatable({}, { __index = SavedMapRot });

  return instance;

end

getmetatable(SavedMapRot).__call = SavedMapRot.__construct;


-- Getters and Setters

---
-- Returns the maprot file path.
--
-- @treturn string The maprot file path
--
function SavedMapRot:getFilePath()
  return self.filePath;
end

---
-- Sets the maprot file path.
--
-- @tparam string _filePath The maprot file path
--
function SavedMapRot:setFilePath(_filePath)
  self.filePath = _filePath;
end


-- Public Methods

---
-- Adds a new map entry to the maprot config file.
--
-- @tparam string _mapName The map name
--
function SavedMapRot:addMap(_mapName)

  local mapRotEntry = _mapName .. ":"   -- map name
                    .. "5:"             -- game mode (ctf)
                    .. "15:"            -- time (15 minutes)
                    .. "1:"             -- allow players to vote for other maps
                    .. "0:"             -- min player
                    .. "16:"            -- max player
                    .. "0"              -- skiplines
                    .. "\n";

  -- Open file in mode "append"
  local file = io.open(self.filePath , "a");

  io.output(file);
  io.write(mapRotEntry);
  io.close(file);

end

---
-- Removes a entry from the maprot config file.
--
-- @tparam string _mapName The map name
--
function SavedMapRot:removeMap(_mapName)

  -- Open tmp file in mode "write"
  local tmpFile = io.open(self.filePath .. ".tmp", "w");

  io.output(tmpFile);

  for line in io.lines(self.filePath) do

    if (not line:match(_mapName)) then
      io.write(line .. "\n");
    end

  end

  io.close(tmpFile);

  -- Replace the map rot file by the temporary file
  os.rename(self.filePath .. ".tmp", self.filePath);

end

---
-- Removes the saved maprot file.
--
function SavedMapRot:remove()
  os.remove(self.filePath);
end


return SavedMapRot;
