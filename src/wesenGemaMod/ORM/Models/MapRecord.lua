---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local LuaORM_API = require("LuaORM/API")
local Map = require("ORM/Models/Map")
local Player = require("ORM/Models/Player")
local fieldTypes = require("ORM/fieldTypes")

local Model = LuaORM_API.Model

---
-- The database table for map records.
--
local MapRecord = Model({

    name = "map_records",

    columns = {
      { name = "milliseconds", fieldType = fieldTypes.unsignedIntegerField },
      { name = "weapon_id", fieldType = fieldTypes.unsignedIntegerField, maxLength = 1 },
      { name = "team_id", fieldType = fieldTypes.unsignedIntegerField, maxLength = 1 },
      { name = "created_at", fieldType = fieldTypes.dateTimeField },
      { name = "player_id", fieldType = fieldTypes.unsignedIntegerField, isForeignKeyTo = Player },
      { name = "map_id", fieldType = fieldTypes.unsignedIntegerField, isForeignKeyTo = Map }
    }
})


return MapRecord
