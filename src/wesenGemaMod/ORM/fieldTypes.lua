---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local LuaORM_API = require("LuaORM/API")
local StringUtils = require("Util/StringUtils")

local FieldType = LuaORM_API.FieldType
local fieldTypes = LuaORM_API.fieldTypes


---
-- Add custom fields for the gema mod database to the list of fields.
--

--
-- Custom char field type that stores case sensitve strings.
--
fieldTypes.caseSensitiveCharField = FieldType({
  luaDataType = "string",
  SQLDataType = "VARBINARY"
})

---
-- Custom field type for ips.
--
fieldTypes.ipField = FieldType({
  luaDataType = "string",
  SQLDataType = "string",

  validator = function(_value)

    local octets = StringUtils:split(_value, "%.")
    if (#octets ~= 4) then
      return false
    end

    for _, octet in ipairs(octets) do

      local octetInteger = tonumber(octet)
      if (octetInteger .. "" ~= octet or octetInteger < 0 or octetInteger > 255) then
        return false
      end

    end

    return true

  end
})


return fieldTypes
