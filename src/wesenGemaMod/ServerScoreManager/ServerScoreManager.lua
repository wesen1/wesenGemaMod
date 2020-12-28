---
-- @author wesen
-- @copyright 2020 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseExtension = require "AC-LuaServer.Core.Extension.BaseExtension"
local MapRankPointsProvider = require "ServerScoreManager.ServerTop.MapRankPointsProvider"
local ServerScoreList = require "ServerScoreManager.ServerTop.ServerScoreList"
local ServerTop = require "ServerScoreManager.ServerTop.ServerTop"
local ServerTopLoader = require "ServerScoreManager.ServerTop.ServerTopLoader"
local tablex = require "pl.tablex"

---
-- Manages the lists of server scores (Points per Player based on their map scores).
--
-- @type ServerScoreManager
--
local ServerScoreManager = BaseExtension:extend()

---
-- The MapRankPointsProvider that will be added to the managed ServerTop's
--
-- @tfield MapRankPointsProvider mapRankPointsProvider
--
ServerScoreManager.mapRankPointsProvider = nil

---
-- The list of server tops
--
-- @tfield ServerTop[] serverTops
--
ServerScoreManager.serverTops = nil


---
-- ServerScoreManager constructor.
--
-- @tparam MapRankPointsProvider|nil _mapRankPointsProvider The MapRankPointsProvider to use
--
function ServerScoreManager:new(_mapRankPointsProvider)
  BaseExtension.new(self, "ServerScoreManager", "GemaGameMode")
  self.mapRankPointsProvider = _mapRankPointsProvider or MapRankPointsProvider()
  self.serverTops = {}
end


-- Getters and Setters

---
-- Returns the list of server tops.
--
-- @treturn ServerTop[] The list of server tops
--
function ServerScoreManager:getServerTops()
  return self.serverTops
end


-- Public Methods

---
-- Returns a server top with a specific id from the list of server tops.
--
-- @tparam string _serverTopId The server top id
--
-- @treturn ServerTop|nil The ServerTop for the given ID
--
function ServerScoreManager:getServerTop(_serverTopId)
  return self.serverTops[_serverTopId]
end


-- Protected Methods

---
-- Initializes this extension.
--
function ServerScoreManager:initialize()

  if (#tablex.keys(self.serverTops) == 0) then
    -- Initialize the ServerTop's only once because they do not change while the GemaGameMode is not enabled
    self.serverTops["main"] = ServerTop(
      ServerTopLoader(self.mapRankPointsProvider),
      ServerScoreList(self.mapRankPointsProvider)
    )
    self.serverTops["main"]:initialize(self.target, "main")

  end

end

---
-- Terminates this extension.
--
function ServerScoreManager:terminate()
  self.serverTops["main"]:terminate()
end


return ServerScoreManager
