---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Map = require("ORM/Models/Map")
local MapRecord = require("ORM/Models/MapRecord")

---
-- Handles saving records to the database.
--
-- @type MapTopSaver
--
local MapTopSaver = setmetatable({}, {});


---
-- MapTopSaver constructor.
--
-- @treturn MapTopSaver The MapTopSaver instance
--
function MapTopSaver:__construct()

  local instance = setmetatable({}, {__index = MapTopSaver});

  return instance;

end

getmetatable(MapTopSaver).__call = MapTopSaver.__construct;


-- Class Methods

---
-- Saves a single record to the database.
--
-- @tparam MapRecord _record The record
-- @tparam string _mapName The map name
--
function MapTopSaver:addRecord(_record, _mapName)

  local player = _record:getPlayer();
  if (player:getId() == -1) then
    player:savePlayer();
  end

  local map = Map:get()
                 :filterByName(_mapName)
                 :findOne()

  if (map == nil) then
    -- The map was added to the maps folder manually instead of using the ingame upload
    map = Map:new({ name = _mapName })
    map:save()
  end

  local existingRecord = MapRecord:get()
                                  :where():column("player_id"):equals(player:getId())
                                  :AND():column("map_id"):equals(map.id)
                                  :findOne()

  if (existingRecord == nil) then

    -- Create a new map record
    MapRecord:new({
        milliseconds = _record:getMilliseconds(),
        weapon_id = _record:getWeapon(),
        team_id = _record:getTeam(),
        created_at = _record:getCreatedAt(),
        player_id = player:getId(),
        map_id = map.id
    }):save()

  else

    existingRecord:update({
        milliseconds = _record:getMilliseconds(),
        weapon_id = _record:getWeapon(),
        team_id = _record:getTeam(),
        created_at = _record:getCreatedAt()
    })

  end

end


return MapTopSaver;
