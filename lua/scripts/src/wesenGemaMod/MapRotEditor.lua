---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local lfs = require("lfs");
local MapChecker = require("Maps/MapChecker");
local Map = require("Maps/Map");

---
-- Class that edits the maprot file and the loaded maprot.
--
-- @type MapRotEditor
--
local MapRotEditor = {};


---
-- The path to the maprot file
--
-- @tfield string mapRotFilePath
--
MapRotEditor.mapRotFilePath = "config/maprot.cfg";


---
-- MapRotEditor constructor.
--
-- @tparam string _mapRotFilePath The path to the maprot file
--
function MapRotEditor:__construct(_mapRotFilePath)

  local instance = {};
  setmetatable(instance, {__index = MapRotEditor});

  if (_mapRotFilePath) then
    instance.mapRotFilePath = _mapRotFilePath;
  end

  return instance;

end


-- Getters and setters

---
-- Returns the path to the map rot file.
--
-- @treturn string The path to the map rot file
--
function MapRotEditor:getMapRotFilePath()
  return self.mapRotFilePath;
end

---
-- Sets the path to the map rot file.
--
-- @tparam string _mapRotFilePath The path to the map rot file
--
function MapRotEditor:setMapRotFilePath(_mapRotFilePath)
  self.mapRotFilePath = _mapRotFilePath;
end


-- Class Methods

---
-- Adds all existing gema maps to the database if they don't exist yet.
--
-- @tparam DataBase _dataBase The database
-- @tparam string _mapsDirectory The path to the maps directory
--
function MapRotEditor:addExistingGemaMapsToDataBase(_dataBase, _mapsDirectory)

  for luaFile in lfs.dir(_mapsDirectory) do

    -- Check whether the file is not "." or ".." and ends with ".cgz"
    if (luaFile ~= "." and luaFile ~= ".." and luaFile:match("^.+%.cgz$")) then

      local mapName = luaFile:gsub(".cgz", "");

      if (not MapChecker:isValidMapName(mapName)) then
        print("Deleting " .. mapName);
        os.remove(_mapsDirectory .. "/" .. luaFile);

      elseif MapChecker:isGema(mapName) then
        print("Loading " .. mapName);
        Map:saveMapName(_dataBase, mapName);
      end

    end

  end

end

---
-- Adds all gema maps from the database to the maprot.
--
-- @tparam DataBase _dataBase The database
--
function MapRotEditor:generateMapRotFromExistingMaps(_dataBase)

  os.remove(self.mapRotFilePath);

  local sql = "SELECT name FROM maps";
  local result = _dataBase:query(sql, true);

  for index, row in ipairs(result) do
    self:addMapToMapRotConfigFile(row["name"]);
  end

end

---
-- Adds a new map to the maprot.
--
-- @tparam string _mapName The map name
--
function MapRotEditor:addMapToMapRotConfigFile(_mapName)

  local mapRotEntry = _mapName .. ":"   -- map name
                    .. "5:"             -- game mode (ctf)
                    .. "15:"            -- time (15 minutes)
                    .. "1:"             -- allow players to vote for other maps
                    .. "0:"             -- min player
                    .. "16:"            -- max player
                    .. "0"             -- skiplines
                    .. "\n";

  -- Open file in mode "append"
  local file = io.open(self.mapRotFilePath , "a");

  io.output(file);
  io.write(mapRotEntry);
  io.close(file);

end

---
-- Adds a map to the loaded map rot.
--
-- @tparam string _mapName The map name
--
function MapRotEditor:addMapToLoadedMapRot(_mapName)

  local mapRotEntry = {
    ["map"] = _mapName,
    ["mode"] = 5,
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
-- Removes a line from the maprot config file.
--
-- @tparam string _mapName The map name
--
function MapRotEditor:removeMapFromMapRotConfigFile(_mapName)

  -- Open tmp file in mode "write"
  local tmpFile = io.open(self.mapRotFilePath .. ".tmp", "w");

  io.output(tmpFile);

  for line in io.lines(self.mapRotFilePath) do

    if (not line:match(_mapName)) then
      io.write(line .. "\n");
    end

  end
  
  io.close(tmpFile);

  -- Replace the map rot file by the temporary file
  os.rename(self.mapRotFilePath .. ".tmp", self.mapRotFilePath);

end

---
-- Removes a map from the loaded map rot.
--
-- @tparam string _mapName The map name
--
function MapRotEditor:removeMapFromLoadedMapRot(_mapName)

  local mapRot = getwholemaprot();
  local updatedMapRot = {};

  for i, mapRotEntry in pairs(mapRot) do
    if (mapRotEntry["map"] ~= _mapName) then
      table.insert(updatedMapRot, mapRotEntry);
    end
  end
  
  setwholemaprot(updatedMapRot);

end


return MapRotEditor;
