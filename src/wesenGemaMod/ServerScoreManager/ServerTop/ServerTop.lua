---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local EventCallback = require "AC-LuaServer.Core.Event.EventCallback"
local Object = require "classic"

---
-- Manages a ServerScoreList.
--
-- @type ServerTop
--
local ServerTop = Object:extend()

---
-- The EventCallback for the "mapRecordAdded" event of the target MapTop
--
-- @tfield EventCallback onMapRecordAddedEventCallback
--
ServerTop.onMapRecordAddedEventCallback = nil

---
-- The target MapTop whose added MapRecord's will be added to this ServerTop
--
-- @tfield MapTop targetMapTop
--
ServerTop.targetMapTop = nil

---
-- The ServerTopLoader
--
-- @tfield ServerTopLoader serverTopLoader
--
ServerTop.serverTopLoader = nil

---
-- The ServerScoreList
--
-- @tfield ServerScoreList serverScoreList
--
ServerTop.serverScoreList = nil


---
-- ServerTop constructor.
--
-- @tparam ServerTopLoader _serverTopLoader The ServerTopLoader to use
-- @tparam ServerScoreList _serverScoreList The ServerScoreList to use
--
function ServerTop:new(_serverTopLoader, _serverScoreList)
  self.serverTopLoader = _serverTopLoader
  self.serverScoreList = _serverScoreList
  self.onMapRecordAddedEventCallback = EventCallback({ object = self, method = "onMapRecordAdded" })
end


-- Getters and Setters

---
-- Returns the ServerScoreList.
--
-- @treturn ServerScoreList The ServerScoreList
--
function ServerTop:getServerScoreList()
  return self.serverScoreList
end


-- Public Methods

---
-- Initializes this ServerTop by loading the initial ServerScore's from the database.
--
-- @tparam GemaGameMode _gemaGameMode The GemaGameMode to which the parent ServerScoreManager was added
-- @tparam string _mapTopType The MapTop type whose records should be added to this ServerTop (e.g. "main")
--
function ServerTop:initialize(_gemaGameMode, _mapTopType)
  self.serverScoreList:initialize(
    self.serverTopLoader:loadInitialServerTop()
  )

  self.targetMapTop = _gemaGameMode:getMapTopHandler():getMapTop(_mapTopType)
  self.targetMapTop:on("mapRecordAdded", self.onMapRecordAddedEventCallback)
end

---
-- Terminates this ServerTop.
--
function ServerTop:terminate()
  self.targetMapTop:off("mapRecordAdded", self.onMapRecordAddedEventCallback)
end


-- Event Handlers

---
-- Event Handler that is called when a MapRecord was added to the target MapTop.
--
-- @tparam MapRecord _mapRecord The MapRecord that was added
-- @tparam MapRecord|nil _previousMapRecord The old MapRecord that was replaced by the MapRecord
--
function ServerTop:onMapRecordAdded(_mapRecord, _previousMapRecord)
  self.serverScoreList:processMapRecord(
    _mapRecord,
    _previousMapRecord and _previousMapRecord:getRank() or nil,
    self.targetMapTop:getMapRecordList()
  )
end


return ServerTop
