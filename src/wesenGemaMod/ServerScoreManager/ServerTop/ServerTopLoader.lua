---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Player = require "Player.Player"
local Object = require "classic"
local MapScore = require "ORM.Models.MapRecord"
local PlayerModel = require "ORM.Models.Player"
local ServerScore = require "ServerScoreManager.ServerTop.ServerScore"

---
-- Provides methods to load the initial server top from the database.
--
-- @type ServerTopLoader
--
local ServerTopLoader = Object:extend()

---
-- The MapRankPointsProvider
--
-- @tfield MapRankPointsProvider mapRankPointsProvider
--
ServerTopLoader.mapRankPointsProvider = nil


---
-- ServerTopLoader constructor.
--
-- @tparam MapRankPointsProvider _mapRankPointsProvider The MapRankPointsProvider to use
--
function ServerTopLoader:new(_mapRankPointsProvider)
  self.mapRankPointsProvider = _mapRankPointsProvider
end


-- Public Methods

---
-- Loads the initial ServerTop from the database.
--
-- @treturn ServerScore[] The list of generated ServerScore's
--
function ServerTopLoader:loadInitialServerTop()

  local mapScores = MapScore:get()
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

  local currentRank = 1
  local currentMapId, mapScore, mapScorePoints, playerRecord, player

  local playerScores = {}
  for i = 1, mapScores:count(), 1 do

    mapScore = mapScores[i]

    if (mapScore.map_id ~= currentMapId) then
      currentMapId = mapScore.map_id
      currentRank = 1
    else
      currentRank = currentRank + 1
    end

    playerRecord = PlayerModel:get()
                              :innerJoinIps()
                              :innerJoinNames()
                              :filterById(mapScore.player_id)
                              :findOne()
    player = Player.createFromPlayerModel(playerRecord)

    mapScorePoints = self.mapRankPointsProvider:getPointsForMapRank(currentRank)

    if (playerScores[mapScore.player_id] == nil) then
      playerScores[mapScore.player_id] = ServerScore(player, mapScorePoints, -1)
    else
      playerScores[mapScore.player_id]:addPoints(mapScorePoints)
    end

    playerScores[mapScore.player_id]:increaseNumberOfMapRecords()
    if (currentRank == 1) then
      playerScores[mapScore.player_id]:increaseNumberOfBestTimes()
    end

  end

  local indexedPlayerScores = {}
  for _, playerScore in pairs(playerScores) do
    table.insert(indexedPlayerScores, playerScore)
  end

  table.sort(
    indexedPlayerScores,
    function(_playerScoreA, _playerScoreB)
      return (_playerScoreA:getPoints() > _playerScoreB:getPoints())
    end
  )

  for rank, playerScore in ipairs(indexedPlayerScores) do
    playerScore:setRank(rank)
  end

  return indexedPlayerScores

end


return ServerTopLoader
