---
-- @author wesen
-- @copyright 2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

---
-- Handles loading of symbol widths from a font config file
--
-- @type SymbolWidthLoader
--
local SymbolWidthLoader = setmetatable({}, {});


---
-- The name of the font config file
--
-- @tfield string fontConfigFileName
--
SymbolWidthLoader.fontConfigFileName = nil;

---
-- The font pixel widths in the format {[character] = width}
-- This attribute will only be set when the instance is created with the _hasFontConfigCache option
--
-- @tfield int[] cachedFontConfig
--
SymbolWidthLoader.cachedFontConfig = nil;


---
-- SymbolWidthLoader constructor.
--
-- @tparam string _fontConfigFileName The font config file name
-- @tparam bool _hasFontConfigCache If true the font config file will be loaded into a class attribute
--
-- @treturn SymbolWidthLoader The SymbolWidthLoader instance
--
function SymbolWidthLoader:__construct(_fontConfigFileName, _hasFontConfigCache)

  local instance = setmetatable({}, {__index = SymbolWidthLoader});

  instance.fontConfigFileName = _fontConfigFileName;

  if (_hasFontConfigCache) then

    -- Load the font config into the cachedFontConfig attribute
    instance.cachedFontConfig = {};
    for index, width in pairs(cfg.totable(_fontConfigFileName)) do
      instance.cachedFontConfig[index] = tonumber(width);
    end

  end

  return instance;

end

getmetatable(SymbolWidthLoader).__call = SymbolWidthLoader.__construct;


-- Public Methods

---
-- Loads and returns the width of a character in pixels.
--
-- @tparam string _character The character
--
-- @treturn int The character width
--
function SymbolWidthLoader:getCharacterWidth(_character)

  -- Get the character identifier
  local character = _character;
  if (character == " ") then
    character = "whitespace";
  elseif (character == "\t") then
    character = "tab";
  end

  if (self.cachedFontConfig) then
    return self:getCharacterWidthFromCachedFontConfig(character);
  else
    return self:getCharacterWidthFromConfigFile(character);
  end

end


-- Private Methods

---
-- Loads and returns the character width in pixels from the cached font config.
--
-- @tparam string _character The character
--
-- @treturn int The character width
--
function SymbolWidthLoader:getCharacterWidthFromCachedFontConfig(_character)

  local width = self.cachedFontConfig[_character];
  if (not width) then
    width = self.cachedFontConfig["default"]
  end

  return width;

end

---
-- Loads and returns the character width in pixels from the config file.
--
-- @tparam string _character The character
--
-- @treturn int The character width
--
function SymbolWidthLoader:getCharacterWidthFromConfigFile(_character)

  local width = cfg.getvalue(self.fontConfigFileName, _character);
  if (not width) then
    width = cfg.getvalue(self.fontConfigFileName, "default");
  end

  return tonumber(width);

end


return SymbolWidthLoader;
