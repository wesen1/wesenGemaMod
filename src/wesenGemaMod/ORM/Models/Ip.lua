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
-- The database table for player ips.
--
local Ip = Model({
    name = "ips",

    columns = {
      -- The maximum length of an ipv4 address is 4 x 3 digits + 4 dots
      { name = "ip", fieldType = fieldTypes.ipField, maxLength = 16, unique = true }
    }
})


return Ip
