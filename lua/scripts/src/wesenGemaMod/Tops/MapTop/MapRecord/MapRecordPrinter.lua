---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Output = require("Outputs/Output");

---
-- @type MapRecordPriner Handles printing of map records.
--
local MapRecordPrinter = {};


---
-- The parent maprecord
--
-- @tfield MapRecord parentMapRecord
--
MapRecordPrinter.parentMapRecord = "";


---
-- MapRecordPrinter constructor.
--
-- @tparam MapRecord _parentMapRecord The parent map record
--
-- @treturn MapRecordPrinter The MapRecordPrinter instance
--
function MapRecordPrinter:__construct(_parentMapRecord)

  local instance = {};
  setmetatable(instance, {__index = MapRecordPrinter});

  instance.parentMapRecord = _parentMapRecord;

  return instance;

end


-- Getters and setters

---
-- Returns the parent maprecord.
--
-- @treturn MapRecord The parent maprecord
--
function MapRecordPrinter:getParentMapRecord()
  return self.parentMapRecord;
end

---
-- Sets the parent maprecord.
--
-- @tparam MapRecord _parentMapRecord The parent maprecord
--
function MapRecordPrinter:setParentMapRecord(_parentMapRecord)
  self.parentMapRecord = _parentMapRecord;
end


-- Class Methods

---
-- Returns the record in the format "Minutes:Seconds,Milliseconds".
--
-- @treturn string The record in the format "Minutes:Seconds,Milliseconds"
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
    local bestTimeString = "\f9*\f2*\fP*\f9*\f2* \fPN\f9E\f2W \fPB\f9E\f2S\fPT \f9T\f2I\fPM\f9E \f2*\fP*\f9*\f2*\fP*";
    Output:print(bestTimeString);
  end

end


return MapRecordPrinter;
