---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local Object = require "classic"

---
-- Provides the score contexts for the map tops and server tops.
-- At the moment it provides a "main" context (fastest time per player) and
-- weapon contexts (fastest time per player per weapon).
--
-- @type ScoreContextProvider
--
local ScoreContextProvider = Object:extend()

-- The available score contexts
ScoreContextProvider.CONTEXT_MAIN = 1
ScoreContextProvider.CONTEXT_KNIFE = 2
ScoreContextProvider.CONTEXT_PISTOL = 3
ScoreContextProvider.CONTEXT_ASSAULT_RIFLE = 4
ScoreContextProvider.CONTEXT_SUBMACHINE_GUN = 5
ScoreContextProvider.CONTEXT_SNIPER_RIFLE = 6
ScoreContextProvider.CONTEXT_SHOTGUN = 7
ScoreContextProvider.CONTEXT_CARBINE = 8

---
-- The mapping of weapon ID's to score contexts
--
-- @tfield int[] WEAPON_SCORE_CONTEXTS
--
ScoreContextProvider.WEAPON_SCORE_CONTEXTS = {
  [LuaServerApi.GUN_KNIFE] = ScoreContextProvider.CONTEXT_KNIFE,
  [LuaServerApi.GUN_PISTOL] = ScoreContextProvider.CONTEXT_PISTOL,
  [LuaServerApi.GUN_ASSAULT] = ScoreContextProvider.CONTEXT_ASSAULT_RIFLE,
  [LuaServerApi.GUN_SUBGUN] = ScoreContextProvider.CONTEXT_SUBMACHINE_GUN,
  [LuaServerApi.GUN_SNIPER] = ScoreContextProvider.CONTEXT_SNIPER_RIFLE,
  [LuaServerApi.GUN_SHOTGUN] = ScoreContextProvider.CONTEXT_SHOTGUN,
  [LuaServerApi.GUN_CARBINE] = ScoreContextProvider.CONTEXT_CARBINE
}

---
-- The list of score context aliases that can be used in commands or config files
-- to reference specific score contexts
-- This list is in the format { <alias> = <context>, ... }
--
-- @tfield int[] scoreContextAliases
--
ScoreContextProvider.scoreContextAliases = nil

---
-- The list of preferred score context aliases that should be shown to players
-- This list is in the format { <context> = <alias>, ... }
--
-- @tfield string[] preferredScoreContextAliases
--
ScoreContextProvider.preferredScoreContextAliases = nil


---
-- ScoreContextProvider constructor.
--
function ScoreContextProvider:new()
  self.scoreContextAliases = {}
  self.preferredScoreContextAliases = {}
end


-- Public Methods

---
-- Initializes this ScoreContextProvider.
--
function ScoreContextProvider:initialize()
  self:initializeScoreContextAliases()
end

---
-- Returns the preferred score context alias for a given score context.
--
-- @tparam int _context The context whose preferred alias to return
--
-- @treturn string|nil The preferred score context alias for the given context
--
function ScoreContextProvider:getPreferredAliasForScoreContext(_context)
  return self.preferredScoreContextAliases[_context]
end

---
-- Adds a score context alias.
--
-- @tparam int _context The score context to add an alias for
-- @tparam string _alias The alias to add for the score context
-- @tparam bool _isPreferredAlias True if the given alias should be the preferred alias for the context, false otherwise
--
function ScoreContextProvider:addScoreContextAlias(_context, _alias, _isPreferredAlias)
  self.scoreContextAliases[_alias] = _context
  if (_isPreferredAlias or not self.preferredScoreContextAliases[_context]) then
    self.preferredScoreContextAliases[_context] = _alias
  end
end

---
-- Returns a score context for a given alias.
--
-- @tparam string _alias The alias whose corresponding score context to return
--
-- @treturn int|nil The score context for the given alias
--
function ScoreContextProvider:getScoreContextByAlias(_alias)
  return self.scoreContextAliases[_alias]
end

---
-- Returns the score contexts for a given list of aliases.
--
-- @tparam string[] _aliases The aliases whose corresponding score contexts to return
--
-- @treturn int[] The score contexts for the given aliases
--
function ScoreContextProvider:getScoreContextsByAliases(_aliases)
  local scoreContexts = {}
  for _, alias in ipairs(_aliases) do
    table.insert(scoreContexts, self:getScoreContextByAlias(alias))
  end

  return scoreContexts
end


---
-- Returns whether a given score context is a weapon context.
--
-- @tparam int _context The context to check
--
-- @treturn bool True if the given context is a weapon context, false otherwise
--
function ScoreContextProvider:isWeaponScoreContext(_context)
  return (self:scoreContextToWeaponId(_context) ~= nil)
end

---
-- Converts a given score context to a weapon ID.
--
-- @tparam int _context The score context whose corresponding weapon ID to return
--
-- @treturn int|nil The weapon ID for the score context
--
function ScoreContextProvider:scoreContextToWeaponId(_context)
  for weaponId, scoreContext in pairs(ScoreContextProvider.WEAPON_SCORE_CONTEXTS) do
    if (scoreContext == _context) then
      return weaponId
    end
  end
end

---
-- Converts a given weapon ID to a score context.
--
-- @tparam int _weaponId The weapon ID whose corresponding score context to return
--
-- @treturn int|nil The score context for the weapon ID
--
function ScoreContextProvider:weaponIdToScoreContext(_weaponId)
  return ScoreContextProvider.WEAPON_SCORE_CONTEXTS[_weaponId]
end


-- Private Methods

---
-- Initializes the default score context aliases.
--
function ScoreContextProvider:initializeScoreContextAliases()

  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_MAIN, "main", true)

  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_KNIFE, "knife", true)
  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_KNIFE, "knife-only")
  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_KNIFE, tostring(LuaServerApi.GUN_KNIFE))

  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_PISTOL, "pistol", true)
  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_PISTOL, "pistol-only")
  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_PISTOL, tostring(LuaServerApi.GUN_PISTOL))

  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_ASSAULT_RIFLE, "assault-rifle", true)
  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_ASSAULT_RIFLE, "assault")
  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_ASSAULT_RIFLE, tostring(LuaServerApi.GUN_ASSAULT))

  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_SUBMACHINE_GUN, "submachine-gun", true)
  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_SUBMACHINE_GUN, "submachine")
  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_SUBMACHINE_GUN, tostring(LuaServerApi.GUN_SUBGUN))

  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_SNIPER_RIFLE, "sniper-rifle", true)
  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_SNIPER_RIFLE, "sniper")
  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_SNIPER_RIFLE, tostring(LuaServerApi.GUN_SNIPER))

  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_SHOTGUN, "shotgun", true)
  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_SHOTGUN, tostring(LuaServerApi.GUN_SHOTGUN))

  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_CARBINE, "carbine", true)
  self:addScoreContextAlias(ScoreContextProvider.CONTEXT_CARBINE, tostring(LuaServerApi.GUN_CARBINE))

end


return ScoreContextProvider
