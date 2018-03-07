---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 

local Output = require("Outputs/Output");

--
-- Handles printing of map records.
--
local MapRecordPrinter = {};

MapRecordPrinter.parentMapRecord = "";

---
-- MapRecordPrinter constructor.
--
-- @param _parentMapRecord (MapRecord) The parent map record
--
function MapRecordPrinter:__construct(_parentMapRecord)

  local instance = {};
  setmetatable(instance, {__index = MapRecordPrinter});

  instance.parentMapRecord = _parentMapRecord;

  return instance;
  
end


---
-- Returns the record in the format "Minutes:Seconds,Milliseconds".
-- 
-- @return (String) Record in the format "Minutes:Seconds,Milliseconds"
--
function MapRecordPrinter:generateTimeString()
  
  local milliseconds = math.fmod(self.parentMapRecord:getMilliseconds(), 1000);
  local seconds = (self.parentMapRecord:getMilliseconds() - milliseconds) / 1000;
  local minutes = math.floor(seconds / 60);
  seconds = seconds - (minutes * 60);

  if (milliseconds < 10) then 
    milliseconds = "00" .. milliseconds
    
  elseif (milliseconds < 100) then
    milliseconds = "0" .. milliseconds;

  end

  if (seconds < 10) then
    seconds = "0" .. seconds;
  end

  if (minutes < 10) then
    minutes = "0" .. minutes;
  end
   
  return minutes .. ":" .. seconds .. "," .. milliseconds;
  
end

---
-- Generates and prints the output for when a player scores.
--
function MapRecordPrinter:printScoreRecord()

  local playerName = self.parentMapRecord:getPlayer():getName();
  local time = self.parentMapRecord:getDisplayString();
  local rank = self.parentMapRecord:getRank();
  local currentRank = self.parentMapRecord:getParentMapTop():getRank(playerName);
  
  local amountRecords = self.parentMapRecord:getParentMapTop():getNumberOfRecords();
  if (currentRank == nil) then
    amountRecords = amountRecords + 1;
  end
  
  local rankString = Output:getColor("mapRecordRank") .. "(Rank " .. rank .. " of " .. amountRecords .. ")";
  if (currentRank ~= nil) then
    local currentRecord = self.parentMapRecord:getParentMapTop():getRecord(currentRank);
    
    if (currentRecord:getMilliseconds() < self.parentMapRecord:getMilliseconds()) then
      rankString = Output:getColor("scoreRecordSlower") .. "(But has a better record)";
    elseif (currentRecord:getMilliseconds() == self.parentMapRecord:getMilliseconds()) then
      rankString = Output:getColor("scoreRecordTied") .. "(Tied his current record)";
    end
  end
    
  local scoreString = Output:getColor("mapRecordName") .. playerName
                   .. Output:getColor("mapRecordInfo") .. " scored after "
                   .. Output:getColor("mapRecordTime") .. time
                   .. Output:getColor("mapRecordInfo") .. " minutes "
                   .. rankString;
  
  Output:print(scoreString);
                                                         
  if (rank == 1) then
    
    local bestTimeString = "\f9*\f2*\fP*\f9*\f2* \fPN\f9E\f2W \fPB\f9E\f2S\fPT \f9T\f2I\fPM\f9E \f2*\fP*\f9*\f2*\fP*"

    Output:print(bestTimeString);

  end

end


return MapRecordPrinter;
