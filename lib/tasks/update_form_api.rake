desc "Update alliance data from api"
task update_from_api: :environment do
  Alliance.update_from_api
end
