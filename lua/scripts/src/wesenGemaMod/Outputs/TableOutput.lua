---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

require("Output");

---
-- Handles outputs of tables to clients.
--
TableOutput = {};

-- TableOutput inherits from Output
setmetatable(TableOutput, { __index = Output });


---
-- Returns the columns of a table in the format [1] => [row1 entries], [2] => [row2 Entries].
--
--
function TableOutput:getColumns(_table, _columns, _offsetX, _offsetY)

  local table = {};
  local offsetX = 0;
  local offsetY = 0;
  local isSubTable = false;
  
  if (_columns and _offsetX and _offsetY) then
    table = _columns;
    offsetX = _offsetX;
    offsetY = _offsetY;
    isSubTable = true;
  end
  
  
  for y, column in ipairs (_table) do
  
    table[x + offsetX] = {};
  
    for y, field in ipairs (column) do
      
      if (type(field) == "table") then
      
        table, offsetX, offsetY = self:getColumns(field, table, offsetX, offsetY);
            
      else
      
        if (isSubTable) then
          offsetY = offsetY + 1;
        end
      
        table[x + offsetX][y + offsetY] = field;
      end
      
    end
    
    if (isSubTable) then
      offsetX = offsetX + 1;
    end
    
  end
  
  return table, offsetX, offsetY;

end


---
-- Prints a table.
-- 
-- @param _table (table) Columns of a row
-- 
function TableOutput:printTable(_table)

  local columns = self:getColumns(_table);
  local widestEntries, entryWidths = self:getWidestEntries(columns);
  
  for y = 1, 8 do
    
    local rowString = "";
    
    for x = 1, 10 do
    
      local field = x .. "|" .. y;
      local fieldWidth = 0;
      
      print (field);
    
      if (columns[x][y]) then

        field = columns[x][y];
        fieldWidth = entryWidths[x][y];

      end
                            
      rowString = rowString .. field .. self:getTabs(fieldWidth, widestEntries[x]);
                
    end
    
    self:print(rowString);
  
  end

end

---
-- Returns the widest entries for every column.
-- 
-- @param _columns (table) Table with at least two columns and one row
-- 
-- @return (table) Longest entries per column
--
function TableOutput:getWidestEntries(_columns)

  local widestEntries = {};
  local entryWidths = {};
  
  for x, column in ipairs(_columns) do
    
    entryWidths[x] = {};

    for y, field in pairs(column) do
        
      local textWidth = self:getTextWidth(field);
      entryWidths[x][y] = textWidth;

      if (widestEntries[x] == nil or widestEntries[x] < textWidth) then
        widestEntries[x] = textWidth;        
      end
             
    end
    
  end
  
  return widestEntries, entryWidths;

end