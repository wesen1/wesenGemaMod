---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

--@todo: Refactor this class

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

---
-- The gema codes. If a map contains one of the symbols at each index in sequence it will
-- be detected as a valid gema map name
--
-- @tfield string[] codes
--
MapNameChecker.codes = nil;

---
-- The maxmium map name length
--
-- @tfield int maximumMapNameLength
--
MapNameChecker.maximumMapNameLength = nil;


function MapNameChecker:__construct()

  local instance = setmetatable({}, { __index = MapNameChecker });

  instance.implicitWords = {"jigsaw", "deadmeat-10"};
  instance.codes = {"g", "3e", "m", "a@4"};
  instance.maximumMapNameLength = 64;

  return instance;

end

getmetatable(MapNameChecker).__call = MapNameChecker.__construct;


-- Getters and setters

---
-- Returns the list of implicit words.
--
-- @treturn string[] The list of implicit words
--
function MapNameChecker:getImplicitWords()
  return self.implicitWords;
end

---
-- Sets the list of implicit words.
--
-- @tparam string[] _implicitWords The list of implicit words
--
function MapNameChecker:setImplicitWords(_implicitWords)
  self.implicitWords = _implicitWords;
end

---
-- Returns the list of map name codes.
--
-- @treturn string[] The list of map name codes
--
function MapNameChecker:getCodes()
  return self.codes;
end

---
-- Sets the list of map name codes.
--
-- @tparam string[] _codes The list of map name codes
--
function MapNameChecker:setCodes(_codes)
  self.codes = _codes;
end


-- Class Methods

---
-- Checks whether a mapname contains g3ema@4 or one of the words "jigsaw" and "deadmeat-10".
--
-- @tparam string _mapName The map name
--
-- @treturn bool True: The map is a gema map
--               False: The map is no gema map
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
-- Checks whether a map name contains one of the implict words.
--
-- @tparam string _mapName The map name
--
-- @treturn bool True: Map name contains one of the implict words
--               False: Map name does not contain one of the implicit words
--
function MapNameChecker:mapNameContainsImplicitWord(_mapName)

  for index, implicitWord in ipairs(self.implicitWords) do

    if (_mapName:find(implicitWord)) then
      return true;
    end

  end

  return false;

end

---
-- Checks whether a map name contains g3ema@4.
--
-- @tparam string _mapName The map name
--
-- @treturn bool True: The map name contains g3ema@4
--               False: The map name does not contain g3ema@4
--
function MapNameChecker:mapNameContainsCodes(_mapName)

  for i = 1, #_mapName - #self.codes + 1 do

    local match = 0

    -- for each code part
    for j = 1, #self.codes do

      -- for each character in code part
      for k = 1, #self.codes[j] do

        -- check whether current position in mapname + code part is one of the codes
        if (_mapName:sub(i+j-1, i+j-1) == self.codes[j]:sub(k, k)) then
          match = match + 1;
        end
      end

      -- exit the loop as soon as one character of the word gema is missing
      if (match ~= j) then
        break;
      end
    end

    -- if map contains the word g3ema@4 return
    if (match == #self.codes) then
      return true;
    end
  end

end

---
-- Checks whether a map name is valid.
--
-- @tparam string _mapName The map name
--
-- @treturn bool True: The name is a valid map name
--               False: The name is not a valid map name
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
  local pattern = "^[%a%d-_.]+$";

  if (_mapName:match(pattern) ~= nil) then
    return true;
  else
    return false;
  end

end


return MapNameChecker;
