---
-- @author wesen
-- @copyright 2017-2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

PLUGIN_NAME = "wesen's gema mod"
PLUGIN_AUTHOR = "wesen"
PLUGIN_VERSION = "0.1"

--
-- Add the path to the wesenGemaMod classes to the package path list
-- in order to be able to omit this path portion in require() calls
--
package.path = package.path .. ";lua/scripts/wesenGemaMod/?.lua"

local GemaMode = require("GemaMode");

local gemaMode = GemaMode(cfg.totable("gemamod"));
gemaMode:initialize();




