paths = Dir[Rails.root.join 'db', 'seed_data', '*.xml'].sort
paths.each do |path|
  Alliance.update_from_file path, predict: path == paths.last
end
