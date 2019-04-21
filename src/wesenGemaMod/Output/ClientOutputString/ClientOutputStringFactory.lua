---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ClientOutputString = require("Output/ClientOutputString/ClientOutputString")
local SymbolWidthLoader = require("Output/ClientOutputString/SymbolWidthLoader")

---
-- Provides static methods to configure a font config and to create ClientOutputString instances.
--
-- @type ClientOutputStringFactory
--
local ClientOutputStringFactory = {}


---
-- The symbol width loader for the ClientOutputString instances
--
-- @tfield SymbolWidthLoader symbolWidthLoader
--
ClientOutputStringFactory.symbolWidthLoader = nil


-- Public Methods

---
-- Sets the symbol width loader for the ClientOutputString instances.
-- This must be called at least once during the boot process.
--
-- @tparam string _fontConfigFileName The name of the font config in the "lua/config" folder
--
function ClientOutputStringFactory.setFontConfigFileName(_fontConfigFileName)
  ClientOutputStringFactory.symbolWidthLoader = SymbolWidthLoader(_fontConfigFileName, true)
end

---
-- Creates and returns a ClientOutputString from a string.
--
-- @tparam string _string The string
--
-- @treturn ClientOutputString The ClientOutputString for the string
--
function ClientOutputStringFactory.getClientOutputString(_string)
  return ClientOutputString(ClientOutputStringFactory.symbolWidthLoader, _string)
end


return ClientOutputStringFactory
