---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

---
-- Converts assaultcube font config to lua config files containing only the width of each character.
--
FontConfigConverter = {};

---
-- Converts a font configuration file to a lua config file only containing the text width of each character.
--
-- Call this function in the main.lua file to convert a font file to a lua config file
--
-- @param _filePath (String) The path to the folder in which the file is located
-- @param _fileName (String) The file name
--
function FontConfigConverter:convertFontConfig(_filePath, _fileName)

  local lines = self:readFile(_filePath .. "/" .. _fileName);
  local fontName = "";

  for index, line in ipairs(lines) do
  
    if (line:find("font ")) then

      local width = 0;
      fontName, width = line:match("font (.*) \".*\" (%d+) %d+ %d+ %d+ %d+.*");      
      cfg.setvalue("font_" .. fontName, "default", width);
    
    elseif (line:find("fontchar")) then

      local width, symbol = line:match("fontchar %d+\ *%d+ *(%d+) .*// (.)");
      cfg.setvalue("font_" .. fontName, symbol, width);

    end

  end 

end

---
-- Reads a file and saves it in a table (each line = table entry).
--
-- @param _filePath (String) File path
--
function FontConfigConverter:readFile(_filePath)

  local lines = {};
  local file = io.open(_filePath, "rb");
  
  for line in io.lines(_filePath) do 
    table.insert(lines, line);
  end
  
  file:close();
  
  return lines;
  
end