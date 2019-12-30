
function VoteEndHandler:onMapVoteEnd(_result, _player, _mapName, _gameMode, _minutes)

  local gemaModeStateUpdater = self.parentGemaMode:getGemaModeStateUpdater();

  if (_result == 1) then
    -- Vote passed

    local mapRot = self.parentGemaMode:getMapRot();

    local nextGemaModeStateUpdate = gemaModeStateUpdater:getNextGemaModeStateUpdate();
    if (nextGemaModeStateUpdate == true) then
      mapRot:loadGemaMapRot();
    elseif (nextGemaModeStateUpdate == false) then
      mapRot:loadRegularMapRot();
    end

    if (nextGemaModeStateUpdate ~= nil) then
      self.output:printTextTemplate(
        "TextTemplate/InfoMessages/MapRot/MapRotLoaded", { ["mapRotType"] = mapRot:getType() }
      )
    end

  else
    gemaModeStateUpdater:resetNextEnvironment();
  end

end
