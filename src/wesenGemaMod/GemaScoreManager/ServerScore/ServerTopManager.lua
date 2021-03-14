---
-- @author wesen
-- @copyright 2020-2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ScoreManager = require "GemaScoreManager.Score.ScoreManager"
local ServerScoreList = require "GemaScoreManager.ServerScore.ServerScoreList"
local ServerTop = require "GemaScoreManager.ServerScore.ServerTop"

---
-- Manages a list of ServerTop's (Points per Player based on their MapScore's).
--
-- @type ServerTopManager
--
local ServerTopManager = ScoreManager:extend()

---
-- The MapScoreStorage that will be used to create ServerTop's
--
-- @tfield MapScoreStorage mapScoreStorage
--
ServerTopManager.mapScoreStorage = nil

---
-- The MapScorePointsProvider that will be used to create ServerTop's
--
-- @tfield MapScorePointsProvider mapScorePointsProvider
--
ServerTopManager.mapScorePointsProvider = nil

---
-- The mergesScoresByPlayerName configuration that will be passed to the created MapTop's
--
-- @tfield bool mergeScoresByPlayerName
--
ServerTopManager.mergeScoresByPlayerName = nil


---
-- ServerTopManager constructor.
--
-- @tparam MapScoreStorage _mapScoreStorage The MapScoreStorage to use
-- @tparam ScoreContextProvider _scoreContextProvider The ScoreContextProvider to use
-- @tparam string[] _contexts The contexts to create ScoreListManager's for
-- @tparam bool _mergeScoresByPlayerName Whether to merge ServerScore's by player names
-- @tparam MapScorePointsProvider|nil _mapScorePointsProvider The MapScorePointsProvider to use
--
function ServerTopManager:new(_mapScoreStorage, _scoreContextProvider, _contexts, _mergeScoresByPlayerName, _mapScorePointsProvider)
  self.mapScoreStorage = _mapScoreStorage
  self.mergeScoresByPlayerName = (_mergeScoresByPlayerName ~= false)
  self.mapScorePointsProvider = _mapScorePointsProvider

  ScoreManager.new(self, _scoreContextProvider, _contexts)
end


-- Getters and Setters

---
-- Returns the list of ServerTop's.
--
-- @treturn ServerTop[] The list of ServerTop's
--
function ServerTopManager:getServerTops()
  return self:getScoreListManagers()
end


-- Public Methods

---
-- Initializes this ServerTopManager.
--
-- @tparam MapTopManager _mapTopManager The MapTopManager to attach the ServerTop's to
--
function ServerTopManager:initialize(_mapTopManager)
  for context, serverTop in pairs(self:getServerTops()) do
    serverTop:setTargetMapTop(_mapTopManager:getMapTop(context))
  end

  ScoreManager.initialize(self)
end

---
-- Returns a ServerTop for a specific context.
--
-- @tparam string _context The ServerTop context
--
-- @treturn ServerTop|nil The ServerTop for the given context
--
function ServerTopManager:getServerTop(_context)
  return self:getScoreListManager(_context)
end


-- Protected Methods

---
-- Creates and returns a ScoreListManager instance.
--
-- @tparam string _context The context to create the ScoreListManager for
--
-- @treturn ServerTop The created ScoreListManager instance
--
function ServerTopManager:createScoreListManager(_context)
  local weaponId
  if (self.scoreContextProvider:isWeaponScoreContext(_context)) then
    weaponId = self.scoreContextProvider:scoreContextToWeaponId(_context)
  end

  return ServerTop(
    ServerScoreList(self.mergeScoresByPlayerName),
    self.mapScoreStorage,
    self.mapScorePointsProvider,
    weaponId
  )
end


return ServerTopManager
