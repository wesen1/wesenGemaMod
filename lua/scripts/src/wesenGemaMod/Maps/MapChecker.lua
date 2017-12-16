---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

--
-- Checks whether maps are valid gemas.
--
MapChecker = {};

--
-- Checks whether a mapname contains g3ema@4 or one of the words "jigsaw" and "deadmeat-10".
--
-- @param string _mapName   The map name
--
-- @return bool  true: The map is a gema map
--               false: The map is no gema map
--
function MapChecker:isGema(_mapName)

  local implicit = {"jigsaw", "deadmeat-10"};
  local code ={"g","3e","m","a@4"};

  local mapName = _mapName:lower();


  -- check whether mapname contains one of the implicit names
  for key, value in ipairs(implicit) do

    -- if mapname contains one of the names return
    if (mapName:find(value)) then
      return true;
    end

  end


  -- check whether map name contains g3ema@4
  for i = 1, #mapName - #code + 1 do

    local match = 0

    -- for each code part
    for j = 1, #code do
  
      -- for each character in code part
      for k = 1, #code[j] do

        -- check whether current position in mapname + code part is one of the codes
        if (mapName:sub(i+j-1, i+j-1) == code[j]:sub(k, k)) then
          match = match + 1;
        end
      end
      
      -- exit the loop as soon as one character of the word gema is missing
      if (match ~= j) then
        break;
      end
    end

    -- if map contains the word g3ema@4 return
    if (match == #code) then
      return true;
    end
  end

  return false;

end