# select ms.solarSystemId as id, ms.solarSystemName as name, ms.regionid, mr.regionname, ms.constellationid, mc.constellationname
# from mapSolarSystems ms, mapRegions mr, mapConstellations mc
# where ms.regionid = mr.regionid
# and ms.constellationid = mc.constellationid
# and ms.security < 0
# and mr.regionname not like '%-%'
# order by ms.solarsystemid asc
