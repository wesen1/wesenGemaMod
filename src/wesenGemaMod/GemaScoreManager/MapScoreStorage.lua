---
-- @author wesen
-- @copyright 2017-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local MapScoreModel = require "ORM.Models.MapRecord"
local MapScore = require "GemaScoreManager.MapScore.MapScore"
local MapModel = require "ORM.Models.Map"
local Object = require "classic"
local Player = require "Player.Player"

---
-- Provides methods to load and save MapScore's from and to a persistent location.
--
-- @type MapScoreStorage
--
local MapScoreStorage = Object:extend()


-- Public Methods

---
-- Loads all MapScore's for a map from the database.
-- Generates and returns a function that iterates over all MapScore's sorted by ranks.
-- It can be used like `for mapScore in mapScoreStorage:loadMapScores() do`.
--
-- @tparam string _mapName The name of the map for which to fetch all MapScore's
--
-- @treturn function The iterator function
--
function MapScoreStorage:loadMapScores(_mapName)

  local mapScoreCollection = MapScoreModel:get()
                                          :innerJoinMaps()
                                          :innerJoinPlayers()
                                          :innerJoinIps()
                                          :innerJoinNames()
                                          :where():column("maps.name"):equals(_mapName)
                                          :orderByMilliseconds():asc()
                                          :find()

  local currentMapScoreRecordIndex = 0
  local numberOfMapScoreRecords = mapScoreCollection:count()

  return function()

    currentMapScoreRecordIndex = currentMapScoreRecordIndex + 1
    if (currentMapScoreRecordIndex <= numberOfMapScoreRecords) then
      local mapScoreRecord = mapScoreCollection[currentMapScoreRecordIndex]
      return self:convertMapScoreRecordToMapScore(mapScoreRecord, currentMapScoreRecordIndex)
    end

  end

end

---
-- Loads all MapScore's from the database.
-- Generates and returns a function that iterates over all MapScore's sorted by maps and ranks.
-- It can be used like `for mapId, mapScore in mapScoreStorage:loadAllMapScores() do`.
--
-- @treturn function The iterator function
--
function MapScoreStorage:loadAllMapScores()

  local mapScoreCollection = MapScoreModel:get()
                                          :select():min("milliseconds")
                                          :innerJoinMaps()
                                          :innerJoinPlayers()
                                          :innerJoinIps()
                                          :innerJoinNames()
                                          :groupBy("player_id")
                                          :groupBy("map_id")
                                          :orderByMapId():asc()
                                          :orderBy("MIN_milliseconds"):asc()
                                          :selectOnlyAggregatedTableColumns(true)
                                          :find()

  local currentMapScoreRecordIndex = 0
  local numberOfMapScoreRecords = mapScoreCollection:count()
  local currentRank = 0
  local currentMapId

  return function()

    currentMapScoreRecordIndex = currentMapScoreRecordIndex + 1
    if (currentMapScoreRecordIndex <= numberOfMapScoreRecords) then
      local mapScoreRecord = mapScoreCollection[currentMapScoreRecordIndex]

      if (mapScoreRecord.map_id ~= currentMapId) then
        currentMapId = mapScoreRecord.map_id
        currentRank = 1
      else
        currentRank = currentRank + 1
      end

      return currentMapId, self:convertMapScoreRecordToMapScore(mapScoreRecord, currentRank)
    end

  end

end

---
-- Saves a single MapScore to the database.
--
-- @tparam MapScore _mapScore The MapScore to save
-- @tparam string _mapName The name of the map to save the MapScore for
--
function MapScoreStorage:saveMapScore(_mapScore, _mapName)

  if (_mapScore:getPlayer():getId() == -1) then
    _mapScore:getPlayer():savePlayer()
  end

  local mapRecord = MapModel:get()
                            :filterByName(_mapName)
                            :findOne()

  if (mapRecord == nil) then
    -- The map was added to the maps folder manually instead of using the ingame upload
    mapRecord = MapModel:new({ name = _mapName })
    mapRecord:save()
  end

  local existingMapScore = MapScoreModel:get()
                                        :where():column("player_id"):equals(_mapScore:getPlayer():getId())
                                        :AND():column("map_id"):equals(mapRecord.id)
                                        :findOne()

  if (existingMapScore == nil) then

    -- Create a new MapScore
    MapScoreModel:new({
      milliseconds = _mapScore:getMilliseconds(),
      weapon_id = _mapScore:getWeaponId(),
      team_id = _mapScore:getTeamId(),
      created_at = _mapScore:getCreatedAt(),
      player_id = _mapScore:getPlayer():getId(),
      map_id = mapRecord.id
    }):save()

  else

    -- Update the existing MapScore
    existingMapScore:update({
      milliseconds = _mapScore:getMilliseconds(),
      weapon_id = _mapScore:getWeaponId(),
      team_id = _mapScore:getTeamId(),
      created_at = _mapScore:getCreatedAt()
    })

  end

end


-- Private Methods

---
-- Converts a given MapScore record to a MapScore.
--
-- @tparam MapScoreModel _mapScoreRecord The MapScore record to convert
-- @tparam int _rank The rank of the MapScore
--
-- @treturn MapScore The created MapScore instance
--
function MapScoreStorage:convertMapScoreRecordToMapScore(_mapScoreRecord, _rank)

  local player = Player.createFromPlayerModel(_mapScoreRecord.players[1])
  local mapScore = MapScore(
    player,
    _mapScoreRecord.milliseconds,
    _mapScoreRecord.weapon_id,
    _mapScoreRecord.team_id,
    _mapScoreRecord.created_at,
    _rank
  )

  return mapScore

end


return MapScoreStorage
