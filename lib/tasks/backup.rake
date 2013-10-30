namespace :backup do
  dump_dir = Rails.root.join 'db', 'dump'

  desc "mongodump prod database"
  task dump_prod: :environment do
    heroku_config = `env -i HOME=$HOME bash  -c 'heroku config'`.split("\n")[1..-1].each_with_object({}) do |line, config|
      m = line.match /(?<key>[A-Z_]*):[\s]*(?<value>.*)/
      config[ m[:key] ] = m[:value]
    end

    uri = URI.parse heroku_config['MONGOHQ_URL']

    %w{alliances solar_systems}.each do |collection|
      `mongodump --host #{uri.host} --port #{uri.port} -u #{uri.user} -p#{uri.password} -d #{uri.path[1..-1]} -c #{collection} -o #{dump_dir}`
    end
  end

  desc "mongorestore prod database"
  task restore_local: :environment do
    Dir[dump_dir.join '*'].each do |collection|
      `mongorestore -d failcascade_development #{collection}`
    end
  end

  desc "Transfer prod data to local"
  task prod_to_local: [:dump_prod, :restore_local]
end
