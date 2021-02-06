---
-- @author wesen
-- @copyright 2021 wesen <wesen-ac@web.de>
-- @release 0.1
-- @license MIT
--

local GeoIPData = require "Util.GeoIP.GeoIPData"
local maxminddb = require "maxminddb"
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

  local geoipCountryData

  local success, result = pcall(function()
    local geoipCountryDatabaseConnection = maxminddb.open("/usr/share/GeoIP/GeoLite2-Country.mmdb")
    geoipCountryData = geoipCountryDatabaseConnection:lookup(_ip)
  end)

  return GeoIPData(
    geoipCountryData and geoipCountryData:get("country", "iso_code") or "--",
    geoipCountryData and geoipCountryData:get("country", "names", "en") or "N/A"
  )

end


return GeoIPDataLoader
