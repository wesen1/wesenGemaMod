---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Checks whether maps are valid gemas.
--
-- @type MapChecker
--
local MapChecker = {};


---
-- The implicit words which will make map names containing one of these words be detected as a valid gema map name
--
-- @tfield string[] implictWords
--
MapChecker.implicitWords = {};

-- Set the words after initializing the attribute as empty table to avoid LDoc error messages
MapChecker.implicitWords = {"jigsaw", "deadmeat-10"};

---
-- The gema codes. If a map contains one of the symbols at each index in sequence it will
-- be detected as a valid gema map name
--
-- @tfield string[] codes
--
MapChecker.codes = {};

-- Set the codes after initializing the attribute as empty table to avoid LDoc error messages
MapChecker.codes = {"g", "3e", "m", "a@4"};


-- Getters and setters

---
-- Returns the list of implicit words.
--
-- @treturn string[] The list of implicit words
--
function MapChecker:getImplicitWords()
  return self.implicitWords;
end

---
-- Sets the list of implicit words.
--
-- @tparam string[] _implicitWords The list of implicit words
--
function MapChecker:setImplicitWords(_implicitWords)
  self.implicitWords = _implicitWords;
end

---
-- Returns the list of map name codes.
--
-- @treturn string[] The list of map name codes
--
function MapChecker:getCodes()
  return self.codes;
end

---
-- Sets the list of map name codes.
--
-- @tparam string[] _codes The list of map name codes
--
function MapChecker:setCodes(_codes)
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
function MapChecker:isGema(_mapName)

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
function MapChecker:mapNameContainsImplicitWord(_mapName)

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
function MapChecker:mapNameContainsCodes(_mapName)

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


return MapChecker;
