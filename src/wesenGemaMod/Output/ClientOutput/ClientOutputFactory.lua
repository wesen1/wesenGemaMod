---
-- @author wesen
-- @copyright 2019 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local ClientOutputString = require("Output/ClientOutput/ClientOutputString/ClientOutputString")
local ClientOutputTable = require("Output/ClientOutput/ClientOutputTable/ClientOutputTable")
local SymbolWidthLoader = require("Output/ClientOutput/Util/SymbolWidthLoader")
local TabStopCalculator = require("Output/ClientOutput/Util/TabStopCalculator")

---
-- Provides static methods to configure a font config and to create ClientOutputString and ClientOutputTable instances.
--
-- @type ClientOutputFactory
--
local ClientOutputFactory = setmetatable({}, {})


---
-- The ClientOutputFactory instance that will be returned by the getInstance method
--
-- @tfield ClientOutputFactory instance
--
ClientOutputFactory.instance = nil

---
-- The symbol width loader for the ClientOutputString and ClientOutputTable instances
--
-- @tfield SymbolWidthLoader symbolWidthLoader
--
ClientOutputFactory.symbolWidthLoader = nil

---
-- The tab stop calculator for the ClientOutputString and ClientOutputTable instances
--
-- @tfield TabStopCalculator tabStopCalculator
--
ClientOutputFactory.tabStopCalculator = nil

---
-- The maximum line width in 3x pixels
--
-- @tfield int maximumLineWidth
--
ClientOutputFactory.maximumLineWidth = 3900

---
-- The default configuration for ClientOutputString's and ClientOutputTable's
-- These values can be overwritten by the config section in each template
--
-- @tfield mixed[] defaultConfiguration
--
ClientOutputFactory.defaultConfiguration = {
  newLineIndent = "",
  lineSplitCharacters = " "
}


---
-- ClientOutputFactory constructor.
--
-- @treturn ClientOutputFactory The ClientOutputFactory instance
--
function ClientOutputFactory:__construct()
  local instance = setmetatable({}, {__index = ClientOutputFactory})
  return instance
end

getmetatable(ClientOutputFactory).__call = ClientOutputFactory.__construct


-- Public Methods

---
-- Returns a ClientOutputFactory instance.
-- This will return the same instance on subsequent calls.
--
-- @treturn ClientOutputFactory The ClientOutputFactory instance
--
function ClientOutputFactory.getInstance()

  if (ClientOutputFactory.instance == nil) then
    ClientOutputFactory.instance = ClientOutputFactory()
  end

  return ClientOutputFactory.instance

end

---
-- Configures this ClientOutputFactory.
--
-- @tparam table _configuration The configuration
--
function ClientOutputFactory:configure(_configuration)

  if (_configuration["fontConfigFileName"] ~= nil) then
    self.symbolWidthLoader = SymbolWidthLoader(_configuration["fontConfigFileName"], true)
    self.tabStopCalculator = TabStopCalculator(self.symbolWidthLoader:getCharacterWidth("\t"))
  end

  if (_configuration["maximumLineWidth"] ~= nil) then
    self.maximumLineWidth = tonumber(_configuration["maximumLineWidth"])
  end

  if (_configuration["newLineIndent"] ~= nil) then
    self.defaultConfiguration["newLineIndent"] = _configuration["newLineIndent"]
  end

  if (_configuration["lineSplitCharacters"] ~= nil) then
    self.defaultConfiguration["lineSplitCharacters"] = _configuration["lineSplitCharacters"]
  end

end


---
-- Creates and returns a ClientOutputString from a string.
--
-- @tparam string _string The string
-- @tparam table _configuration The configuration for the ClientOutputString (optional)
--
-- @treturn ClientOutputString The ClientOutputString for the string
--
function ClientOutputFactory:getClientOutputString(_string, _configuration)

  local clientOutputString = ClientOutputString(
    self.symbolWidthLoader, self.tabStopCalculator, self.maximumLineWidth
  )

  clientOutputString:configure(self.defaultConfiguration)
  if (_configuration) then
    clientOutputString:configure(_configuration)
  end

  clientOutputString:parse(_string)

  return clientOutputString

end

---
-- Creates and returns a ClientOutputTable from a table.
--
-- @tparam table _table The table
-- @tparam table _configuration The configuration for the ClientOutputTable (optional)
--
-- @treturn ClientOutputTable The ClientOutputTable for the table
--
function ClientOutputFactory:getClientOutputTable(_table, _configuration)

  local clientOutputTable = ClientOutputTable(
    self.symbolWidthLoader, self.tabStopCalculator, self.maximumLineWidth
  )

  clientOutputTable:configure(self.defaultConfiguration)
  if (_configuration) then
    clientOutputTable:configure(_configuration)
  end

  clientOutputTable:parse(_table)

  return clientOutputTable

end


return ClientOutputFactory
