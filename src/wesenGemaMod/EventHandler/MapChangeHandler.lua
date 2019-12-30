
---
-- Event handler which is called when the map is changed.
--
-- @tparam string _mapName The name of the new map
-- @tparam int _gameMode The game mode
--
function MapChangeHandler:handleEvent(_mapName, _gameMode)

  self:updateGemaModeState();

  -- If gema mode is still active
  if (self.parentGemaMode:getIsActive()) then

    local mapTopHandler = self.parentGemaMode:getMapTopHandler();
    local mapTop = mapTopHandler:getMapTop("main");

    -- Load the map records for the map
    mapTop:loadRecords(_mapName);

    -- Print the map statistics for the map to all players
    self.output:printTableTemplate(
      "TableTemplate/MapTop/MapStatistics", { ["mapRecordList"] = mapTop:getMapRecordList() }
    )

  end

end


-- Private Methods

---
-- Updates the gema mode state if necessary.
--
function MapChangeHandler:updateGemaModeState()

  local gemaModeStateUpdater = self.parentGemaMode:getGemaModeStateUpdater();
  local newGemaModeState = gemaModeStateUpdater:switchToNextEnvironment();

  if (newGemaModeState ~= nil) then
    self.output:printTextTemplate(
      "TextTemplate/InfoMessages/GemaModeState/GemaModeStateChange",
      { ["isGemaModeActive"] = newGemaModeState }
    )
  end

end
