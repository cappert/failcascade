solar_systems_xml = Rails.root.join 'db', 'null_solar_systems.xml'

MultiXml.parse(File.read solar_systems_xml)['resultset']['row'].each do |row|
  attributes = row['field'].each_with_object({}) do |attr, attrs|
    attrs[attr['name']] = attr['__content__']
  end

  ss = SolarSystem.where(_id: attributes['id']).first_or_initialize

  ss.name               = attributes['name']
  ss.region_id          = attributes['regionid']
  ss.region_name        = attributes['regionname']
  ss.constellation_id   = attributes['constellationid']
  ss.constellation_name = attributes['constellationname']
  ss.security           = attributes['security']

  ss.save
end
