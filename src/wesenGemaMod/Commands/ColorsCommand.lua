---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("CommandHandler/BaseCommand");

---
-- Command !colors.
-- Displays all available colors to a player
-- ColorsCommand inherits from BaseCommand
--
-- @type ColorsCommand
--
local ColorsCommand = setmetatable({}, {__index = BaseCommand});


---
-- ColorsCommand constructor.
--
-- @tparam CommandList _parentCommandList The parent command list
--
-- @treturn ColorsCommand The ColorsCommand instance
--
function ColorsCommand:__construct(_parentCommandList)

  local instance = BaseCommand(
    _parentCommandList,
    "!colors",
    0,
    "Colors",
    {},
    "Shows a list of all available colors"
  );
  setmetatable(instance, {__index = ColorsCommand});

  return instance;

end

getmetatable(ColorsCommand).__call = ColorsCommand.__construct;


-- Public Methods

---
-- Displays all available colors to a player.
--
-- @tparam Player _player The player who executed the command
-- @tparam string[] _arguments The list of arguments which were passed by the player
--
function ColorsCommand:execute(_player, _arguments)

  local symbols = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
  local outputText = "";

  for i = 1, #symbols do
    local symbol = symbols:sub(i,i);
    outputText = outputText .. "\f" .. symbol .. " " .. symbol;
  end

  self.output:print(outputText, _player);

end


return ColorsCommand;
