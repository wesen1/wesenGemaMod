---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

local Output = require("Outputs/Output");

--
-- Handles printing of maptop related values.
--
local MapTopPrinter = {};

-- MapTop to which this MapTopPrinter belongs
MapTopPrinter.parentMapTop = "";

--
-- MapTopPrinter constructor.
--
-- @param MapTop _parentMapTop  The parent MapTop
--
function MapTopPrinter:__construct(_parentMapTop)

  local instance = {};
  setmetatable(instance, {__index = MapTopPrinter});
  
  instance.parentMapTop = _parentMapTop;
  
  return instance;
  
end

-- Getters and Setters
function MapTopPrinter:setParentMapTop(_parentMapTop)
  self.parentMapTop = _parentMapTop;
end

function MapTopPrinter:getParentMapTop()
  return self.parentMapTop;
end


--
-- Prints the maptop to a player.
--
-- @param int _cn  Client number of the player
--
function MapTopPrinter:printMapTop(_cn)

  local colorLoader = self.parentMapTop:getParentGemaMod():getColorLoader();

  if (self.parentMapTop:isEmpty()) then
    Output:print(colorLoader:getColor("emptyTop") .. "No records found for this map.", _cn);
  else

    local amountDisplayRecords = 5;
    local amountRecords = self.parentMapTop:getNumberOfRecords();

    if (amountRecords < 5) then
      amountDisplayRecords = amountRecords;
    end

    Output:print(colorLoader:getColor("mapTopInfo") .. "The " .. amountDisplayRecords .. " best players of this map are:", _cn);
  
    local startRank = 1;
    local limit = 5;
    
    if (amountRecords < startRank + limit) then
      limit = amountRecords - (startRank - 1);
    end
    
    
    local maxRankLength = string.len(limit);
      
    for i = startRank, limit do
    
    
      local rank = string.rep("0", maxRankLength - string.len(i)) .. i;
      local record = self.parentMapTop:getRecord(i);
      local output = colorLoader:getColor("mapRecordRank") .. rank .. ") "
                  .. colorLoader:getColor("mapRecordTime") .. record:getDisplayString()
                  .. colorLoader:getColor("mapRecordInfo") .. " by "
                  .. colorLoader:getColor("mapRecordName") .. record:getPlayer():getName();
      Output:print(output, _cn);
    
    end
    
  end

end

--
-- Prints statistics about the current map.
--
-- @param int _cn  Player to which the statistics will be printed
--
function MapTopPrinter:printMapStatistics(_cn)

  local colorLoader = self.parentMapTop:getParentGemaMod():getColorLoader();

  if (self.parentMapTop:isEmpty()) then
    Output:print(colorLoader:getColor("emptyTop") .. "No records found for this map.", _cn);
  
  else
  
    local bestRecord = self.parentMapTop:getRecord(1);
    local amountRecords = self.parentMapTop:getNumberOfRecords();
            
    local playerAmountString = amountRecords .. " player";
    if (amountRecords ~= 1) then
      playerAmountString = playerAmountString .. "s"
    end
      
    Output:print(colorLoader:getColor("mapTopInfo") .. "This map was finished by " .. playerAmountString, _cn);
    Output:print(
      colorLoader:getColor("mapRecordInfo") .. "The best record of this map is "
      .. colorLoader:getColor("mapRecordTime") .. bestRecord:getDisplayString()
      .. colorLoader:getColor("mapRecordInfo") .. " by "
      .. colorLoader:getColor("mapRecordName") .. bestRecord:getPlayer():getName(),
      _cn
    );

  end

end


return MapTopPrinter;
