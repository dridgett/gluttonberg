require File.expand_path('../boot', __FILE__)
require 'rails/all'
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Gluttonberg
  class Application < Rails::Application
    # config.autoload_paths += %W(#{config.root}/extras)
    config.action_view.javascript_expansions[:defaults] = %w()
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end