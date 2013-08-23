desc "Update data from api"
task update_from_api: [:update_alliances, :update_solar_systems]

task update_alliances: :environment do
  Alliance.update_from_api
end

task update_solar_systems: :environment do
  SolarSystem.update_from_api
  Alliance.count_sov
end
