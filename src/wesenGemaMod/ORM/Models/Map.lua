---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local LuaORM_API = require("LuaORM/API")
local Player = require("ORM/Models/Player")
local fieldTypes = require("ORM/fieldTypes")

local Model = LuaORM_API.Model

---
-- The database table for maps.
--
local Map = Model({
    name = "maps",

    columns = {
      -- The maximum possible length of a map name is 64 characters
      { name = "name", fieldType = fieldTypes.caseSensitiveCharField, maxLength = 64, escapeValue = true, unique = true },

      --
      -- These fields may be empty because the server owner can directly copy
      -- gema maps to the maps folder instead of uploading them ingame
      --
      { name = "uploaded_at", fieldType = fieldTypes.dateTimeField, mustBeSet = false },
      { name = "uploaded_by", fieldType = fieldTypes.unsignedIntegerField, isForeignKeyTo = Player, mustBeSet = false }
    }
})


return Map
