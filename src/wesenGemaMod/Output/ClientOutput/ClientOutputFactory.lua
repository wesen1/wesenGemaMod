---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ClientOutputString = require("Output/ClientOutput/ClientOutputString/ClientOutputString")
local ClientOutputTable = require("Output/ClientOutput/ClientOutputTable/ClientOutputTable")
local SymbolWidthLoader = require("Output/ClientOutput/Util/SymbolWidthLoader")

---
-- Provides static methods to configure a font config and to create ClientOutputString and ClientOutputTable instances.
--
-- @type ClientOutputFactory
--
local ClientOutputFactory = {}


---
-- The symbol width loader for the ClientOutputString and ClientOutputTable instances
--
-- @tfield SymbolWidthLoader symbolWidthLoader
--
ClientOutputFactory.symbolWidthLoader = nil


-- Public Methods

---
-- Sets the symbol width loader for the ClientOutputString instances.
-- This must be called at least once during the boot process.
--
-- @tparam string _fontConfigFileName The name of the font config in the "lua/config" folder
--
function ClientOutputFactory.setFontConfigFileName(_fontConfigFileName)
  ClientOutputFactory.symbolWidthLoader = SymbolWidthLoader(_fontConfigFileName, true)
end

---
-- Creates and returns a ClientOutputString from a string.
--
-- @tparam string _string The string
--
-- @treturn ClientOutputString The ClientOutputString for the string
--
function ClientOutputFactory.getClientOutputString(_string)
  return ClientOutputString(ClientOutputFactory.symbolWidthLoader, _string)
end

---
-- Creates and returns a ClientOutputTable from a table.
--
-- @tparam table _table The table
--
-- @treturn ClientOutputTable The ClientOutputTable for the table
--
function ClientOutputFactory.getClientOutputTable(_table)
  return ClientOutputTable.createFromTable(ClientOutputFactory.symbolWidthLoader, _table)
end


return ClientOutputFactory
