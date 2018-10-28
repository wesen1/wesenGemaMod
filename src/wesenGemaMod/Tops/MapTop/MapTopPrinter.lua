---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local WeaponNameFetcher = require("WeaponHandler/WeaponNameFetcher");
local MapRecordPrinter = require("Tops/MapTop/MapRecordList/MapRecordPrinter");

---
-- Handles printing of maptop related values.
--
-- @type MapTopPrinter
--
local MapTopPrinter = setmetatable({}, {});


---
-- The map record printer
--
-- @tfield MapRecordPrinter mapRecordPrinter
--
MapTopPrinter.mapRecordPrinter = nil;

---
-- The output
--
-- @tfield Output output
--
MapTopPrinter.output = nil;

---
-- The weapon name fetcher
--
-- @tfield WeaponNameFetcher weaponNameFetcher
--
MapTopPrinter.weaponNameFetcher = nil;


---
-- MapTopPrinter constructor.
--
-- @tparam Output _output The output
--
-- @treturn MapTopPrinter The MapTopPrinter instance
--
function MapTopPrinter:__construct(_output)

  local instance = setmetatable({}, {__index = MapTopPrinter});

  instance.output = _output;

  instance.mapRecordPrinter = MapRecordPrinter(_output);
  instance.weaponNameFetcher = WeaponNameFetcher();

  return instance;

end

getmetatable(MapTopPrinter).__call = MapTopPrinter.__construct;


-- Public Methods

---
-- Prints the maptop to a player.
--
-- @tparam int _player The player to which the maptop will be printed
--
function MapTopPrinter:printMapTop(_mapTop, _player)

  local mapRecordList = _mapTop:getMapRecordList();

  if (mapRecordList:getNumberOfRecords() == 0) then
    self.output:print(self.output:getColor("emptyTop") .. "No records found for this map.", _player);
  else

    -- Get the number of display records
    local numberOfDisplayRecords = 5;
    local numberOfRecords = mapRecordList:getNumberOfRecords();
    if (numberOfRecords < numberOfDisplayRecords) then
      numberOfDisplayRecords = numberOfRecords;
    end

    local startRank = 1;
    local endRank = startRank + (numberOfDisplayRecords - 1);

    local mapTopTitle = self:getMapTopTitle(startRank, numberOfDisplayRecords);
    self.output:print(mapTopTitle, _player);


    local maxRankLength = string.len(endRank);

    local mapTopEntries = {};
    local mapTopContainsIp = false;

    for i = startRank, endRank, 1 do

      local record = mapRecordList:getRecordByRank(i);
      local mapTopEntry = self.mapRecordPrinter:getMapTopOutputTableRow(record, maxRankLength);
      table.insert(mapTopEntries, mapTopEntry);

      if (mapTopEntry[2] ~= " ") then
        mapTopContainsIp = true;
      end

    end

    if (not mapTopContainsIp) then

      for _, mapTopEntry in ipairs(mapTopEntries) do
        mapTopEntry[2] = mapTopEntry[3];
        mapTopEntry[3] = mapTopEntry[4];
        mapTopEntry[4] = nil;
      end

    end

    self.output:printTable(mapTopEntries, _player, true);

  end

end

---
-- Prints statistics about the current map.
--
-- @tparam MapTop _mapTop The map top
-- @tparam Player _player The player to which the statistics will be printed
--
function MapTopPrinter:printMapStatistics(_mapTop, _player)

  local mapRecordList = _mapTop:getMapRecordList();
  local numberOfRecords = mapRecordList:getNumberOfRecords();
  if (numberOfRecords > 0) then

    local mapTopSummary = self.output:getColor("mapTopInfo") .. "This map was finished by "
                      .. self.output:getColor("mapTopNumberOfRecords") .. "%d "
                      .. self.output:getColor("mapTopInfo") .. "player%s";

    if (numberOfRecords == 1) then
      mapTopSummary = string.format(mapTopSummary, numberOfRecords, "");
    else
      mapTopSummary = string.format(mapTopSummary, numberOfRecords, "s");
    end

    self.output:print(mapTopSummary, _player);

  end

  self:printBestMapRecord(_mapTop, _player);

end

---
-- Prints the best map record to a player.
--
-- @tparam MapTop _mapTop The map top
-- @tparam Player _player The player
--
function MapTopPrinter:printBestMapRecord(_mapTop, _player)

  local mapRecordList = _mapTop:getMapRecordList();

  if (mapRecordList:getNumberOfRecords() == 0) then
    self.output:print(self.output:getColor("emptyTop") .. "No records found for this map.", _player);
  else
    local bestMapRecord = mapRecordList:getRecordByRank(1);
    self.mapRecordPrinter:printBestMapRecord(bestMapRecord, _player);
  end

end



-- Private Methods

---
-- Returns the map top title.
--
-- @tparam int _startRank The start rank of displayed records
-- @tparam int _endRank The end rank of the displayed records
--
-- @treturn string The map top title
--
function MapTopPrinter:getMapTopTitle(_startRank, _numberOfDisplayRecords)

  local mapTopTitle;

  if (_startRank == 1) then
    mapTopTitle = self.output:getColor("mapTopInfo") .. "The "
               .. self.output:getColor("mapTopNumberOfRecords") .. "%d "
               .. self.output:getColor("mapTopInfo") .. "best player%s of this map %s:";

    if (_numberOfDisplayRecords == 1) then
      mapTopTitle = string.format(mapTopTitle, _numberOfDisplayRecords, "", "is");
    else
      mapTopTitle = string.format(mapTopTitle, _numberOfDisplayRecords, "s", "are");
    end

  else

    mapTopTitle = self.output:getColor("mapTopInfo") .. "Rank "
               .. self.output:getColor("mapTopRank") .. _startRank;

    if (_numberOfDisplayRecords == 1) then
      mapTopTitle = mapTopTitle .. self.output:getColor("mapTopInfo") .. " is:";
    else

      local endRank = _startRank + (_numberOfDisplayRecords - 1);
      mapTopTitle = mapTopTitle .. self.output:getColor("mapTopInfo") .. " to "
                                .. self.output:getColor("mapTopRank") .. endRank
                                .. self.output:getColor("mapTopInfo") .. " are:";
    end

  end

  return mapTopTitle;

end


return MapTopPrinter;
