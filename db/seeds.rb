Dir[Rails.root.join 'db', 'seed_data', '*.xml'].each do |path|
  Alliance.update_from_file path
end
