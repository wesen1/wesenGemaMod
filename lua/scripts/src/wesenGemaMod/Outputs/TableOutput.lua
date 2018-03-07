---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

local Output = require("Outputs/Output");

---
-- Handles outputs of tables to clients.
--
local TableOutput = {};

-- TableOutput inherits from Output
setmetatable(TableOutput, { __index = Output });


---
-- Returns the rows of a table in the format [1] => [row1 entries], [2] => [row2 Entries].
-- Merges all sub tables into the main table schema.
--
-- @param table _table The table content in the format [1] => [row1 entries], [2] => [row2 entries], etc
--
function TableOutput:getRows(_table)

  local table = {};
  local offsetY = 0;
  local longestRow = 0;
  local longestColumn = 0;
  
  for y, row in pairs (_table) do
  
    table[y + offsetY] = {};
  
    for x, field in pairs (row) do
      
      if (type(field) == "table") then
      
        local subTable = self:getRows(field);
        
        for subY, subRow in pairs(subTable) do
        
          if (table[y + offsetY] == nil) then 
            table[y + offsetY] = {};
          end
        
          for subX, subField in pairs(subRow) do
            table[y + offsetY][x + subX - 1] = subField;
            
            if (x + subX - 1 > longestRow) then
              longestRow = x + subX - 1;
            end
            
          end
          
          if (subY ~= #subTable) then
            offsetY = offsetY + 1;
          end
          
        end

      else
      
        local offsetX = 0;
      
        while (table[y + offsetY][x + offsetX] ~= nil) do
          offsetX = offsetX + 1;
        end
      
        table[y + offsetY][x + offsetX] = field;
        
        if (x + offsetX > longestRow) then
          longestRow = x + offsetX;
        end
        
      end
      
    end
    
    if (y + offsetY > longestColumn) then
      longestColumn = y + offsetY;
    end
        
  end
  
  return table, longestRow, longestColumn;

end


---
-- Prints a table.
-- 
-- @param _table (table) Columns of a row
-- @tparam int _cn The player client number to which the table will be printed
-- 
function TableOutput:printTable(_table, _cn)

  local rows, longestRow, longestColumn = self:getRows(_table);
  local widestEntries, entryWidths = self:getWidestEntries(rows);
    
    
  for y = 1, longestColumn, 1 do

    local rowString = "";
    
    local rowLength = 0;
    
    for x, field in pairs(rows[y]) do
      if (x > rowLength) then
        rowLength = x;
      end
    end
    
    for x = 1, longestRow, 1 do
    
      local field = "";
      local fieldWidth = 0;
    
      if (rows[y] ~= nil and rows[y][x] ~= nil) then
      
        field = rows[y][x];
        fieldWidth = entryWidths[y][x];
        
      end
      
      rowString = rowString .. field;
      
      if (x < rowLength) then
        rowString = rowString .. self:getTabs(fieldWidth, widestEntries[x]);
      end

    end

    self:print(rowString, _cn);
  
  end

end

---
-- Returns the widest entries for every column.
-- 
-- @param _columns (table) Table with at least two columns and one row
-- 
-- @return (table) Longest entries per column
--
function TableOutput:getWidestEntries(_rows)

  local widestEntries = {};
  local entryWidths = {};
  
  for y, row in pairs(_rows) do
    
    entryWidths[y] = {};
    widestEntries[y] = 0;

    for x, field in pairs(row) do
            
      local textWidth = self:getTextWidth(field);
      
      entryWidths[y][x] = textWidth;

      if (widestEntries[x] == nil or widestEntries[x] < textWidth) then
        widestEntries[x] = textWidth;        
      end
             
    end
    
  end
  
  return widestEntries, entryWidths;

end


return TableOutput;
