---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Ip = require("ORM/Models/Ip")
local LuaORM_API = require("LuaORM/API")
local Name = require("ORM/Models/Name")
local fieldTypes = require("ORM/fieldTypes")

local Model = LuaORM_API.Model

---
-- The database table for the combinations of player ips and names.
--
local Player = Model({
    name = "players",

    columns = {
      { name = "ip_id", fieldType = fieldTypes.unsignedIntegerField, isForeignKeyTo = Ip },
      { name = "name_id", fieldType = fieldTypes.unsignedIntegerField, isForeignKeyTo = Name }
    }
})


return Player
