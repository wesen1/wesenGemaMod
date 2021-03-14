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

-- The available weapon filter modes for MapScoreStorage.saveMapScore()
MapScoreStorage.SAVE_WEAPON_FILTER_MODE_MATCHES = 1
MapScoreStorage.SAVE_WEAPON_FILTER_MODE_NOT_MATCHES = 2


-- Public Methods

---
-- Loads all MapScore's for a map from the database.
-- Generates and returns a function that iterates over all MapScore's sorted by ranks.
-- It can be used like `for mapScore in mapScoreStorage:loadMapScores() do`.
--
-- @tparam string _mapName The name of the map for which to fetch all MapScore's
-- @tparam int _weaponId The ID of the weapon to filter the MapScore's by (optional)
--
-- @treturn function The iterator function
--
function MapScoreStorage:loadMapScores(_mapName, _weaponId)

  local mapScoreQuery = MapScoreModel:get()
                                     :innerJoinMaps()
                                     :innerJoinPlayers()
                                     :innerJoinIps()
                                     :innerJoinNames()
                                     :where():column("maps.name"):equals(_mapName)
                                     :orderByMilliseconds():asc()

  if (_weaponId ~= nil) then
    mapScoreQuery:where():column("map_records.weapon_id"):equals(_weaponId)
  end

  local mapScoreCollection = mapScoreQuery:find()

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
-- @tparam int _weaponId The ID of the weapon to filter the MapScore's by (optional)
--
-- @treturn function The iterator function
--
function MapScoreStorage:loadAllMapScores(_weaponId)

  local mapScoreQuery = MapScoreModel:get()
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

  if (_weaponId ~= nil) then
    mapScoreQuery:where():column("map_records.weapon_id"):equals(_weaponId)
  end

  local mapScoreCollection = mapScoreQuery:find()

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
-- @tparam int[] _filterWeaponIds The weapon IDs to filter by when searching for an existing MapScore to update
-- @tparam int _filterMode The mode to use to filter existing MapScore's by weapon ID's (One of the SAVE_WEAPON_FILTER_MODE_* constants)
--
function MapScoreStorage:saveMapScore(_mapScore, _mapName, _filterWeaponIds, _filterMode)

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

  local mapScoreQuery = MapScoreModel:get()
                                     :where():column("player_id"):equals(_mapScore:getPlayer():getId())
                                     :AND():column("map_id"):equals(mapRecord.id)

  if (_filterMode == MapScoreStorage.SAVE_WEAPON_FILTER_MODE_MATCHES) then
    mapScoreQuery:AND():column("weapon_id"):isInList(_filterWeaponIds)
  else
    mapScoreQuery:AND():NOT():column("weapon_id"):isInList(_filterWeaponIds)
  end

  local existingMapScore = mapScoreQuery:findOne()
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
