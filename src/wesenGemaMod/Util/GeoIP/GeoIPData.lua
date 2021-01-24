---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local Object = require "classic"

---
-- Contains GeoIP data for a single IP.
--
-- @type GeoIPData
--
local GeoIPData = Object:extend()

---
-- The country code
--
-- @tfield string countryCode
--
GeoIPData.countryCode = nil

---
-- The country name
--
-- @tfield string countryName
--
GeoIPData.countryName = nil


---
-- GeoIPData constructor.
--
-- @tparam string _countryCode The country code
-- @tparam string _countryName The country name
--
function GeoIPData:new(_countryCode, _countryName)
  self.countryCode = _countryCode
  self.countryName = _countryName
end


-- Public Methods

---
-- Returns the country code for the IP.
--
-- @treturn string The country code
--
function GeoIPData:getCountryCode()
  return self.countryCode
end

---
-- Returns the country name for the IP.
--
-- @treturn string The country name
--
function GeoIPData:getCountryName()
  return self.countryName
end


return GeoIPData
