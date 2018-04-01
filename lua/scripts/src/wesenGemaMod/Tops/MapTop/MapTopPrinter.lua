---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Output = require("Outputs/Output");
local TableOutput = require("Outputs/TableOutput");
local WeaponNameFetcher = require("WeaponNameFetcher");

---
-- Handles printing of maptop related values.
--
-- @type MapTopPrinter
--
local MapTopPrinter = {};


---
-- The parent map top
--
-- @tfield MapTop parentMapTop
--
MapTopPrinter.parentMapTop = "";


---
-- MapTopPrinter constructor.
--
-- @tparam MapTop _parentMapTop The parent map top
--
-- @treturn MapTopPrinter The MapTopPrinter instance
--
function MapTopPrinter:__construct(_parentMapTop)

  local instance = {};
  setmetatable(instance, {__index = MapTopPrinter});

  instance.parentMapTop = _parentMapTop;

  return instance;

end


-- Getters and Setters

---
-- Returns the parent map top.
--
-- @treturn MapTop The parent map top
--
function MapTopPrinter:getParentMapTop()
  return self.parentMapTop;
end

---
-- Sets the parent map top.
--
-- @tparam MapTop _parentMapTop The parent map top
--
function MapTopPrinter:setParentMapTop(_parentMapTop)
  self.parentMapTop = _parentMapTop;
end


-- Class Methods

---
-- Prints the maptop to a player.
--
-- @tparam int _cn The client number of the player to which the maptop will be printed
--
function MapTopPrinter:printMapTop(_cn)

  if (self.parentMapTop:isEmpty()) then
    Output:print(Output:getColor("emptyTop") .. "No records found for this map.", _cn);
  else

    local amountDisplayRecords = 5;
    local amountRecords = self.parentMapTop:getNumberOfRecords();

    if (amountRecords < 5) then
      amountDisplayRecords = amountRecords;
    end

    local mapTopTitle = "The %i best player%s of this map %s:";

    if (amountDisplayRecords == 1) then
      mapTopTitle = string.format(mapTopTitle, amountDisplayRecords, "", "is");
    else
      mapTopTitle = string.format(mapTopTitle, amountDisplayRecords, "s", "are");
    end

    Output:print(Output:getColor("mapTopInfo") .. mapTopTitle, _cn);

    local startRank = 1;
    local limit = 4;

    if (amountRecords < startRank + limit) then
      limit = amountRecords - startRank;
    end


    local maxRankLength = string.len(startRank + limit);

    local mapTopEntries = {};

    for i = startRank, startRank + limit do

      local rank = string.rep("0", maxRankLength - string.len(i)) .. i;
      local record = self.parentMapTop:getRecord(i);

      local mapTopEntry = {
        [1] = Output:getColor("mapRecordRank") .. rank .. ") "
     .. Output:getColor("mapRecordTime") .. record:getDisplayString()
     .. Output:getColor("mapRecordInfo") .. " by "
     .. Output:getColor("mapRecordName") .. record:getPlayer():getName(),

        [2] = self:getTeamColor(record:getTeam()) .. WeaponNameFetcher:getWeaponName(record:getWeapon()),

        [3] = Output:getColor("mapRecordTimeStamp") .. os.date("%Y-%m-%d", record:getCreatedAt())
      }

      table.insert(mapTopEntries, mapTopEntry);

    end

    TableOutput:printTable(mapTopEntries, _cn, true);

  end

end

---
-- Prints statistics about the current map.
--
-- @tparam int _cn The client number of the player to which the statistics will be printed
--
function MapTopPrinter:printMapStatistics(_cn)

  if (self.parentMapTop:isEmpty()) then
    Output:print(Output:getColor("emptyTop") .. "No records found for this map.", _cn);

  else

    local bestRecord = self.parentMapTop:getRecord(1);
    local amountRecords = self.parentMapTop:getNumberOfRecords();

    local playerAmountString = amountRecords .. " player";
    if (amountRecords ~= 1) then
      playerAmountString = playerAmountString .. "s"
    end

    Output:print(Output:getColor("mapTopInfo") .. "This map was finished by " .. playerAmountString, _cn);
    Output:print(
      Output:getColor("mapRecordInfo") .. "The best record of this map is "
   .. Output:getColor("mapRecordTime") .. bestRecord:getDisplayString()
   .. Output:getColor("mapRecordInfo") .. " by "
   .. Output:getColor("mapRecordName") .. bestRecord:getPlayer():getName()
   .. Output:getColor("mapRecordInfo") .. " with "
   .. self:getTeamColor(bestRecord:getTeam()) .. WeaponNameFetcher:getWeaponName(bestRecord:getWeapon()),
      _cn
    );

  end

end

---
-- Returns the color for a team.
--
-- @tparam int _teamId The team id
--
-- @treturn string The team color
--
function MapTopPrinter:getTeamColor(_teamId)

  if (_teamId == TEAM_RVSF) then
    return Output:getColor("teamRVSF");
  elseif (_teamId == TEAM_CLA) then
    return Output:getColor("teamCLA");
  end 

end


return MapTopPrinter;
