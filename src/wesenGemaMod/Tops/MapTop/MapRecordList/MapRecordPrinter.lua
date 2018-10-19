---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local TimePrinter = require("TimeHandler/TimePrinter");
local WeaponNameFetcher = require("WeaponHandler/WeaponNameFetcher");

---
-- Handles printing of map records.
--
-- @type MapRecordPriner
--
local MapRecordPrinter = setmetatable({}, {});


---
-- The output
--
-- @tfield Output output
--
MapRecordPrinter.output = nil;

---
-- The time printer
--
-- @tfield TimePrinter timePrinter
--
MapRecordPrinter.timePrinter = nil;

---
-- The weapon name fetcher
--
-- @tfield WeaponNameFetcher weaponNameFetcher
--
MapRecordPrinter.weaponNameFetcher = nil;


---
-- MapRecordPrinter constructor.
--
-- @tparam Output _output The output
--
-- @treturn MapRecordPrinter The MapRecordPrinter instance
--
function MapRecordPrinter:__construct(_output)

  local instance = setmetatable({}, {__index = MapRecordPrinter});

  instance.output = _output;
  instance.timePrinter = TimePrinter();
  instance.weaponNameFetcher = WeaponNameFetcher();

  return instance;

end

getmetatable(MapRecordPrinter).__call = MapRecordPrinter.__construct;


-- Public Methods

---
-- Generates and prints the output for when a player scores.
--
function MapRecordPrinter:printScoreRecord(_mapRecord)

  local scoreString = self:getScoreString(_mapRecord);
  local rankString = self:getRankString(_mapRecord);
  self.output:print(scoreString .. " " .. rankString);

  if (_mapRecord:getRank() == 1) then
    local bestTimeString = "\f9*\f2*\fP*\f9*\f2* \fPN\f9E\f2W \fPB\f9E\f2S\fPT \f9T\f2I\fPM\f9E \f2*\fP*\f9*\f2*\fP*";
    self.output:print(bestTimeString);
  end

end

---
-- Returns an output table row for the map top.
--
-- @tparam MapRecord _mapRecord The map record
-- @tparam int _maximumRankLength The maximum rank string length
--
-- @treturn table The output table row
--
function MapRecordPrinter:getMapTopOutputTableRow(_mapRecord, _maximumRankLength)

  -- Pad the rank with zeros so that all entries have the same number of digits in their ranks
  local rank = _mapRecord:getRank();
  local rankString = string.rep("0", _maximumRankLength - string.len(rank)) .. rank;

  local playerName = _mapRecord:getPlayer():getName();
  local isPlayerNameUnique = _mapRecord:getParentMapRecordList():isPlayerNameUnique(playerName);
  
  local weaponName = self.weaponNameFetcher:getWeaponName(_mapRecord:getWeapon());

  local mapTopEntry = {};
  
  -- Column 1: Rank, time and player name
  mapTopEntry[1] = self.output:getColor("mapRecordRank") .. rankString .. ") "
                .. self.output:getColor("mapRecordTime") .. self:getTimeString(_mapRecord)
                .. self.output:getColor("mapRecordInfo") .. " by "
                .. self.output:getColor("mapRecordName") .. playerName;

  -- Column 2: IP (if necessary)
  if (not isPlayerNameUnique) then
    mapTopEntry[2] = self.output:getColor("mapRecordInfo") .. " ("
                  .. self.output:getColor("ip") .. _mapRecord:getPlayer():getIpString()
                  .. self.output:getColor("mapRecordInfo") .. ")";
  else
    mapTopEntry[2] = " ";
  end

  -- Column 3: Weapon name in team color
  mapTopEntry[3] = self.output:getTeamColor(_mapRecord:getTeam()) .. weaponName;
  
  -- Column 4: Date
  mapTopEntry[4] = self.output:getColor("mapRecordTimeStamp") .. os.date("%Y-%m-%d", _mapRecord:getCreatedAt());
  
  return mapTopEntry;

end

---
-- Prints the best map record string for the map statistics to a player.
--
-- @tparam MapRecord _bestMapRecord The best map record
-- @tparam Player _player The player to print the best map record to
--
-- @treturn string The best map record string
--
function MapRecordPrinter:printBestMapRecord(_bestMapRecord, _player)

  local weaponName = self.weaponNameFetcher:getWeaponName(_bestMapRecord:getWeapon());

  self.output:print(self.output:getColor("mapRecordInfo") .. "The best record of this map is "
                 .. self.output:getColor("mapRecordTime") .. self:getTimeString(_bestMapRecord)
                 .. self.output:getColor("mapRecordInfo") .. " by "
                 .. self.output:getColor("mapRecordName") .. _bestMapRecord:getPlayer():getName()
                 .. self.output:getColor("mapRecordInfo") .. " with "
                 .. self.output:getTeamColor(_bestMapRecord:getTeam()) .. weaponName,
                 _player);

end


-- Private Methods

---
-- Returns the score string.
-- Example "x scored after 1:23,456 minutes with Knife Only".
--
-- @tparam MapRecord _mapRecord The map record
--
-- @treturn string The score string
--
function MapRecordPrinter:getScoreString(_mapRecord)

  local weaponName = self.weaponNameFetcher:getWeaponName(_mapRecord:getWeapon());

  return self.output:getColor("mapRecordName") .. _mapRecord:getPlayer():getName()
      .. self.output:getColor("mapRecordInfo") .. " scored after "
      .. self.output:getColor("mapRecordTime") .. self:getTimeString(_mapRecord)
      .. self.output:getColor("mapRecordInfo") .. " minutes with "
      .. self.output:getTeamColor(_mapRecord:getTeam()) .. weaponName;

end

---
-- Returns the time string for a map record.
-- Generates the time string if the map record has no cached time string.
--
-- @tparam MapRecord _mapRecord The map record
--
-- @treturn string The time string
--
function MapRecordPrinter:getTimeString(_mapRecord)

  if (not _mapRecord:getTimeString()) then
    local milliseconds = _mapRecord:getMilliseconds();
    local timeString = self.timePrinter:generateTimeString(milliseconds, "%02i:%02s,%03v");
    _mapRecord:setTimeString(timeString);
  end

  return _mapRecord:getTimeString();

end

---
-- Returns the rank string.
-- Will return (rank x of y) if the record is a new personal best time or "(But has a better record)"/("Tied his current record").
--
-- @tparam MapRecord _mapRecord The map record
--
-- @treturn string The rank string
--
function MapRecordPrinter:getRankString(_mapRecord)

  local rankString = nil;
  local mapRecordList = _mapRecord:getParentMapRecordList();
  local currentRecord = mapRecordList:getRecordByPlayer(_mapRecord:getPlayer());
  
  if (mapRecordList:isPersonalBestTime(_mapRecord)) then
    
    local numberOfRecords = mapRecordList:getNumberOfRecords();
    if (currentRecord == nil) then
      -- This method is called before the record is added to the map record list, so the number of records must be increased by one
      numberOfRecords = numberOfRecords + 1;
    end

    rankString = self.output:getColor("mapRecordRank") .. "(Rank " .. _mapRecord:getRank() .. " of " .. numberOfRecords .. ")";

  else
    -- The current record will always be set here, because no current record means new personal best time
    if (currentRecord:getMilliseconds() < _mapRecord:getMilliseconds()) then
      rankString = self.output:getColor("scoreRecordSlower") .. "(But has a better record)";
    elseif (currentRecord:getMilliseconds() == _mapRecord:getMilliseconds()) then
      rankString = self.output:getColor("scoreRecordTied") .. "(Tied his current record)";
    end
  
  end

  return rankString;
  
end


return MapRecordPrinter;
