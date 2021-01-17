---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Exception = require "AC-LuaServer.Core.Util.Exception.Exception"

---
-- Exception for the case that player specific information should be fetched via a player name but
-- multiple Player's with that name were found.
--
-- @type PlayerNameNotUniqueException
--
local PlayerNameNotUniqueException = Exception:extend()

---
-- The name of the player related information that was attempted to be fetched
--
-- @tfield string fetchedInformationName
--
PlayerNameNotUniqueException.fetchedInformationName = nil

---
-- The player name that caused the Exception
--
-- @tfield string playerName
--
PlayerNameNotUniqueException.playerName = nil

---
-- The list of Player's that matched the player name
--
-- @tfield Player[] matchingPlayers
--
PlayerNameNotUniqueException.matchingPlayers = nil


---
-- PlayerNameNotUniqueException constructor.
--
-- @tparam string _fetchedInformationName The name of the information that was attempted to be fetched
-- @tparam string _playerName The player name that caused the Exception
-- @tparam string _matchingPlayers The list of Player's that matched the player name
--
function PlayerNameNotUniqueException:new(_fetchedInformationName, _playerName, _matchingPlayers)
  self.fetchedInformationName = _fetchedInformationName
  self.playerName = _playerName
  self.matchingPlayers = _matchingPlayers
end


-- Getters and Setters

---
-- Returns the name of the player related information that was attempted to be fetched.
--
-- @treturn string The name of the player related information that was attempted to be fetched
--
function PlayerNameNotUniqueException:getFetchedInformationName()
  return self.fetchedInformationName
end

---
-- Returns the player name that caused the Exception.
--
-- @treturn string The player name that caused the Exception
--
function PlayerNameNotUniqueException:getPlayerName()
  return self.playerName
end

---
-- Returns the Player's that matched the player name.
--
-- @treturn Player[] The Player's that matched the player name
--
function PlayerNameNotUniqueException:getMatchingPlayers()
  return self.matchingPlayers
end


-- Public Methods

---
-- Returns this Exception's message as a string.
--
-- @treturn string The Exception message as a string
--
function PlayerNameNotUniqueException:getMessage()
  return string.format(
    "Could not fetch %s by player name \"%s\": Multiple Player's found with that name",
    self.fetchedInformationName,
    self.playerName
  )
end


return PlayerNameNotUniqueException
