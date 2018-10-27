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
-- The gema codes. If a map contains one of the symbols at each index in sequence it will
-- be detected as a valid gema map name
--
-- @tfield string[] codes
--
MapNameChecker.codes = nil;
MapNameChecker.codes = { {"g"}, {"3" , "e"}, {"m"}, {"a", "@" , "4"} };

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

  if (_mapName:match(pattern) ~= nil) then
    return true;
  else
    return false;
  end

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

  local mapNameLetter;

  local codePosition = 1;
  local numberOfCodes = #self.codes;
  local numberOfCodeMatches = 0;

  -- Iterate over all map name letters
  for mapNamePosition, mapNameLetter in ipairs(StringUtils:split(_mapName, "")) do

    -- Check if the map name letter matches the code part at the current code position
    for _, codePartLetter in ipairs(self.codes[codePosition]) do
      if (mapNameLetter == codePartLetter) then
        numberOfCodeMatches = numberOfCodeMatches + 1;
        break;
      end
    end

    if (numberOfCodeMatches == codePosition) then
      -- The code part matched the current map name letter

      if (codePosition == numberOfCodes) then
        break;
      else
        codePosition = codePosition + 1;
      end
    else
      codePosition = 1;
      numberOfCodeMatches = 0;
    end
  end

  if (numberOfCodeMatches == numberOfCodes) then
    return true;
  else
    return false;
  end

end


return MapNameChecker;
