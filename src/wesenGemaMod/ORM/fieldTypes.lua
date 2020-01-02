---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local LuaORM_API = require("LuaORM/API")

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

    -- Check if the string contains four numbers that are divided by dots
    local octets = {value:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")}
    if (#octets ~= 4) then
      return false
    end

    -- Check if each octet is valid
    for _, octet in ipairs(octets) do

      local octetInteger = tonumber(octet)
      if (octetInteger < 0 or octetInteger > 255) then
        -- The octet is not between 0 and 255
        return false
      elseif (octet:sub(0, 1) == "0" and octetInteger ~= 0) then
        -- The octet starts with zero but is a different value than 0
        return false
      end

    end

    return true

  end
})


return fieldTypes
