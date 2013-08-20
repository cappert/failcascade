require File.expand_path('../boot', __FILE__)

# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

Bundler.require(:default, Rails.env)

module Failcascade
  class Application < Rails::Application
    config.assets.paths << Dir[Rails.root.join "vendor", "assets", "*"]
  end
end
