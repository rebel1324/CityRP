FindMetaTable("Player").GeoIP = function(pl)
	if not GeoIP then require 'geoip' end
	if not GeoIP then error "GeoIP not found" end
	return GeoIP.Get(pl:IP())
end