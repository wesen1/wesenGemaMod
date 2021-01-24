---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local GeoipCountryDatabaseConnection = require "geoip.country"
local GeoIPData = require "Util.GeoIP.GeoIPData"
local Object = require "classic"

---
-- Wrapper around a GeoIP library.
-- This is done so that the GeoIP library can easily be switched without changing the rest of the code.
--
-- @type GeoIPDataLoader
--
local GeoIPDataLoader = Object:extend()


-- Public Methods

---
-- Loads and returns the GeoIPData for a given IP.
--
-- @tparam string _ip The IP for which to load the GeoIPData
--
-- @treturn GeoIPData The GeoIPData for the given IP
--
function GeoIPDataLoader:loadGeoIPDataForIp(_ip)

  local geoipCountryDatabaseConnection = GeoipCountryDatabaseConnection.open()
  local geoipCountryData = geoipCountryDatabaseConnection:query_by_addr(_ip)
  geoipCountryDatabaseConnection:close()

  return GeoIPData(geoipCountryData.code, geoipCountryData.name)

end


return GeoIPDataLoader
