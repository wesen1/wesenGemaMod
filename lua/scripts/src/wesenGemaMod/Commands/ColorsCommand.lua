---
-- @author wesen
-- @copyright 2017-2018 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local BaseCommand = require("Commands/BaseCommand");
local Output = require("Outputs/Output");

---
-- @type ColorsCommand Command !colors - Displays all available colors to a player.
--
local ColorsCommand = {};

-- ColorsCommand inherits from BaseCommand
setmetatable(ColorsCommand, {__index = BaseCommand});


---
-- ColorsCommand constructor.
--
-- @tparam CommandLister _parentCommandLister The parent command lister
--
-- @treturn ColorsCommand The ColorsCommand instance
--
function ColorsCommand:__construct(_parentCommandLister)

  local instance = BaseCommand:__construct(_parentCommandLister, "colors", 0, "Colors");
  setmetatable(instance, {__index = ColorsCommand});

  instance:setDescription("Shows a list of all available colors");

  return instance;

end

---
-- Displays all available colors to a player.
--
-- @tparam int _cn The client number of the player who executed the command
-- @tparam string[] _args The list of arguments which were passed by the player
--
function ColorsCommand:execute(_cn, _args)

  local symbols = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
  local output = "";

  for i = 1, #symbols do
    local symbol = symbols:sub(i,i);
    output = output .. "\f" .. symbol .. " " .. symbol;
  end

  Output:print(output, _cn);

end


return ColorsCommand;
