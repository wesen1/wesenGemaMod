---
-- @author wesen
-- @copyright 2017 wesen <wesen-ac@web.de>
-- 
PLUGIN_NAME = "wesen's basic gema mod";
PLUGIN_AUTHOR = "wesen";
PLUGIN_VERSION = 0.1;

include("ac_server");

autoloader = dofile("lua/scripts/src/autoloader.lua");
autoloader:register("lua/scripts/src/wesenGemaMod");
autoloader:requireFiles("lua/scripts/src/wesenGemaMod/Events");

require("DataBase");
require("MapTop");
require("ColorLoader");
require("CommandLister");

commandLister = CommandLister:__construct();
commandLister = autoloader:loadCommands("lua/scripts/src/wesenGemaMod/Commands/Commands", commandLister);
dataBase = DataBase:__construct("assaultcube", "password", "assaultcube_gema");
mapTop = MapTop:__construct();
colorLoader = ColorLoader:__construct("colors");
players = {};

