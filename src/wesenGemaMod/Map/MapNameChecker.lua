---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local StringUtils = require("Util/StringUtils");

---
-- Checks whether map names are valid gema map names.
--
-- @type MapNameChecker
--
local MapNameChecker = setmetatable({}, {});


---
-- The implicit words which will make map names containing one of these words be detected as a valid gema map name
--
-- @tfield string[] implictWords
--
MapNameChecker.implicitWords = nil;
MapNameChecker.implicitWords = {"jigsaw", "deadmeat-10"};

---
-- The maxmium map name length
--
-- @tfield int maximumMapNameLength
--
MapNameChecker.maximumMapNameLength = 64;


---
-- MapNameChecker constructor.
--
-- @treturn MapNameChecker The MapNameChecker instance
--
function MapNameChecker:__construct()

  local instance = setmetatable({}, {__index = MapNameChecker});

  return instance;

end

getmetatable(MapNameChecker).__call = MapNameChecker.__construct;


-- Public Methods

---
-- Checks whether a map name contains g3ema@4 or one of the words "jigsaw" and "deadmeat-10".
--
-- @tparam string _mapName The map name
--
-- @treturn bool True if the map name is a gema map name, false otherwise
--
function MapNameChecker:isGemaMapName(_mapName)

  local mapName = _mapName:lower();

  if (self:mapNameContainsImplicitWord(mapName)) then
    return true;
  elseif (self:mapNameContainsCodes(mapName)) then
    return true;
  else
    return false;
  end

end

---
-- Checks whether a map name is valid.
--
-- @tparam string _mapName The map name
--
-- @treturn bool True if the name is a valid map name, false otherwise
--
function MapNameChecker:isValidMapName(_mapName)

  -- Check whether the map name is longer than the maximum allowed length
  if (string.len(_mapName) > self.maximumMapNameLength) then
    return false;
  end

  -- Check whether the map name contains forbidden characters
  -- Map names may contain only '-', '_', '.', letters and digits

  ---
  -- See https://www.lua.org/pil/20.2.html
  --
  -- ^ = Start of the word
  -- [] = Group of characters that can be at a character position to match the group
  -- + = Repeat the group 1+ times
  -- $ = End of the word
  -- %a = letters
  -- %d = digits
  --
  local pattern = "^[%a%d%-_%.]+$";

  return (_mapName:match(pattern) ~= nil)

end


-- Private Methods

---
-- Checks whether a map name contains one of the implict words.
--
-- @tparam string _mapName The map name (must be lowercase)
--
-- @treturn bool True if the map name contains one of the implict words, false otherwise
--
function MapNameChecker:mapNameContainsImplicitWord(_mapName)

  for _, implicitWord in ipairs(self.implicitWords) do
    if (_mapName:find(implicitWord) ~= nil) then
      return true;
    end
  end

  return false;

end

---
-- Checks whether a map name contains g3ema@4.
--
-- @tparam string _mapName The map name (must be lowercase)
--
-- @treturn bool True if the map name contains g3ema@4, false otherwise
--
function MapNameChecker:mapNameContainsCodes(_mapName)
  return (_mapName:match("g[e3]m[a4@]") ~= nil)
end


return MapNameChecker;
