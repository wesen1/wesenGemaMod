---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local MapChecker = require("Maps/MapChecker");
local Output = require("Outputs/Output");

---
-- Class that handles map changes.
--
-- @type MapChangeHandler
--
local MapChangeHandler = {};


---
-- The parent gema mod to which this EventHandler belongs
--
-- @tfield GemaMod parentGemaMod
--
MapChangeHandler.parentGemaMod = "";


---
-- MapChangeHandler constructor.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
-- @treturn MapChangeHandler The MapChangeHandler instance
--
function MapChangeHandler:__construct(_parentGemaMod)

  local instance = {};
  setmetatable(instance, {__index = MapChangeHandler});

  instance.parentGemaMod = _parentGemaMod;

  return instance;

end


-- Getters and setters

---
-- Returns the parent gema mod.
--
-- @treturn GemaMod The parent gema mod
--
function MapChangeHandler:getParentGemaMod()
  return self.parentGemaMod;
end

---
-- Sets the parent gema mod.
--
-- @tparam GemaMod _parentGemaMod The parent gema mod
--
function MapChangeHandler:setParentGemaMod(_parentGemaMod)
  self.parentGemaMod = _parentGemaMod;
end


-- Class Methods

---
-- Event handler which is called when the map is changed.
--
-- @tparam string _mapName The name of the new map
-- @tparam int _gameMode The game mode
--
function MapChangeHandler:onMapChange(_mapName, _gameMode)

  if (self.parentGemaMod:getIsActive()) then

    if (not MapChecker:isGema(_mapName) or _gameMode ~= GM_CTF) then
      self.parentGemaMod:setIsActive(false);
      Output:print(Output:getColor("info") .. "[INFO] The gema mode was automatically disabled. Vote a gema map in ctf to reenable it.");
      return;
    end

    local mapTop = self.parentGemaMod:getMapTop();

    mapTop:setMapName(_mapName);
    mapTop:loadRecords(_mapName);

    for cn, player in pairs(self.parentGemaMod:getPlayers()) do
      mapTop:printMapStatistics(cn);
    end

    self.parentGemaMod:setRemainingExtendMinutes(20);

  else
    if (MapChecker:isGema(_mapName) and _gameMode == GM_CTF) then
      self.parentGemaMod:setIsActive(true);
      Output:print(Output:getColor("info") .. "[INFO] The gema mode was automatically enabled.");
      self:onMapChange(_mapName, _gameMode);
    end
  end

end


return MapChangeHandler;
