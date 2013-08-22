namespace :backup do
  dump_dir = Rails.root.join 'db', 'dump'

  desc "mongodump prod database"
  task dump_prod: :environment do
    heroku_config = `env -i HOME=$HOME bash  -c 'heroku config'`.split("\n")[1..-1].each_with_object({}) do |line, config|
      m = line.match /(?<key>[A-Z_]*):[\s]*(?<value>.*)/
      config[ m[:key] ] = m[:value]
    end

    uri = URI.parse heroku_config['MONGOHQ_URL']

    `mongodump --host #{uri.host} --port #{uri.port} -u #{uri.user} -p#{uri.password} -d #{uri.path[1..-1]} -c alliances -o #{dump_dir}`
  end

  desc "mongorestore prod database"
  task restore_local: :environment do
    `mongorestore -d failcascade_development #{Dir[dump_dir.join '*'].first}`
  end

  desc "Transfer prod data to local"
  task prod_to_local: [:dump_prod, :restore_local]
end
