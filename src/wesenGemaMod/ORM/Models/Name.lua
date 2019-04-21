---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local LuaORM_API = require("LuaORM/API")
local fieldTypes = require("ORM/fieldTypes")

local Model = LuaORM_API.Model

---
-- The database table for player names.
--
local Name = Model({
    name = "names",

    columns = {
      -- The maximum possible length of a player name is 15 characters
      { name = "name", fieldType = fieldTypes.caseSensitiveCharField, maxLength = 15, escapeValue = true, unique = true }
    }
})


return Name
