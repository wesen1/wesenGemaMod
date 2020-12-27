---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local MapRecord = require("Tops/MapTop/MapRecordList/MapRecord");
local MapScore = require("ORM/Models/MapRecord")
local Player = require("Player/Player");

---
-- Loads the map records from the database.
--
-- @type MapTopLoader
--
local MapTopLoader = setmetatable({}, {});


---
-- MapTopLoader constructor.
--
-- @treturn MapTopLoader The MapTopLoader instance
--
function MapTopLoader:__construct()

  local instance = setmetatable({}, {__index = MapTopLoader});

  return instance;

end

getmetatable(MapTopLoader).__call = MapTopLoader.__construct;


-- Public Methods

---
-- Loads all records for a map from the database.
--
-- @tparam string _mapName The name of the map for which the records will be fetched
-- @tparam MapRecordList _mapRecordList The map record list into which the records will be saved
--
function MapTopLoader:fetchRecords(_mapName, _mapRecordList)

  _mapRecordList:clear();

  local mapScores = MapScore:get()
                            :innerJoinMaps()
                            :innerJoinPlayers()
                            :innerJoinIps()
                            :innerJoinNames()
                            :where():column("maps.name"):equals(_mapName)
                            :orderByMilliseconds():asc()
                            :find()

  for i = 1, mapScores:count(), 1 do

    local mapScore = mapScores[i]

    local player = Player(-1, mapScore.players[1].ips[1].ip, mapScore.players[1].names[1].name)
    local record = MapRecord(player, mapScore.milliseconds, mapScore.weapon_id, mapScore.team_id, _mapRecordList, i)
    record:setCreatedAt(mapScore.created_at)

    _mapRecordList:addRecord(record);

  end

end


return MapTopLoader;
