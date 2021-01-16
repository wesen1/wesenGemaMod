---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require "CommandManager.BaseCommand"
local LuaServerApi = require "AC-LuaServer.Core.LuaServerApi"
local StaticString = require "Output.StaticString"
local TemplateException = require "AC-LuaServer.Core.Util.Exception.TemplateException"

---
-- Command !reset.
-- Allows a player to instantly respawn while not causing info messages in other players consoles.
--
-- @type ResetCommand
--
local ResetCommand = BaseCommand:extend()


---
-- ResetCommand constructor.
--
function ResetCommand:new()

  self.super.new(
    self,
    StaticString("resetCommandName"):getString(),
    0,
    StaticString("resetCommandGroupName"):getString(),
    {},
    StaticString("resetCommandDescription"):getString(),
    {
      StaticString("resetCommandAlias1"):getString(),
      StaticString("resetCommandAlias2"):getString()
    }
  )

end


-- Public Methods

---
-- Instantly respawns a player.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
-- @raise Error when the player is currently in one of the spectate modes
--
function ResetCommand:execute(_player, _arguments)

  local currentTeam = LuaServerApi.getteam(_player:getCn())
  if (currentTeam == LuaServerApi.TEAM_CLA_SPECT or
      currentTeam == LuaServerApi.TEAM_RVSF_SPECT or
      currentTeam == LuaServerApi.TEAM_SPECT
  ) then
    error(TemplateException(
      "Commands/Reset/Exceptions/PlayerIsSpectator", {}
    ))
  end

  -- Kill the player to make him drop the flag if he currently holds it
  LuaServerApi:forcedeath(_player:getCn())

  -- Set the players primary weapon to his next requested primary weapon
  LuaServerApi.setprimary(_player:getCn(), LuaServerApi.getnextprimary(_player:getCn()))

  if (LuaServerApi.callhandler("onPlayerSpawn", _player:getCn()) ~= LuaServerApi.PLUGIN_BLOCK) then

    -- Respawn the player at a random spawn point
    LuaServerApi.sendspawn(_player:getCn())

    LuaServerApi.callhandler("onPlayerSpawnAfter", _player:getCn())

  end

end


return ResetCommand
