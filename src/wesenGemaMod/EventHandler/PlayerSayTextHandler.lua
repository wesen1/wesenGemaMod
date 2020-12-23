---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseEventHandler = require("EventHandler/BaseEventHandler");
local TemplateFactory = require("Output/Template/TemplateFactory")

---
-- Class that handles players saying texts.
-- PlayerSayTextHandler inherits from BaseEventHandler
--
-- @type PlayerSayTextHandler
--
local PlayerSayTextHandler = setmetatable({}, {__index = BaseEventHandler});


---
-- PlayerSayTextHandler constructor.
--
-- @tparam GemaMode _parentGemaMode The parent gema mode
--
-- @treturn PlayerSayTextHandler The PlayerSayTextHandler instance
--
function PlayerSayTextHandler:__construct(_parentGemaMode)

  local instance = BaseEventHandler(_parentGemaMode, "onPlayerSayText");
  setmetatable(instance, {__index = PlayerSayTextHandler});

  return instance;

end

getmetatable(PlayerSayTextHandler).__call = PlayerSayTextHandler.__construct;


-- Public Methods

---
-- Event handler which is called when a player says text.
-- Logs the text that the player said and either executes a command or outputs the text to the other players
--
-- @tparam int _cn The client number of the player
-- @tparam string _text The text that the player sent
--
-- @treturn int|nil PLUGIN_BLOCK if the gema mode is active or nil
--
function PlayerSayTextHandler:handleEvent(_cn, _text)

  local player = self:getPlayerByCn(_cn)

  logline(ACLOG_INFO,
    TemplateFactory.getInstance():getTemplate(
      "TextTemplate/LogMessages/PlayerSayText", { player = player, text = _text}
    ):renderAsText():getOutputRows()[1]
  );

end


return PlayerSayTextHandler;
