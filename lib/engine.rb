require 'gluttonberg'
require 'rails'

module Gluttonberg
  class Engine < Rails::Engine
    # Config defaults
    config.widget_factory_name = "default factory name"
    config.mount_at = '/'
    config.admin_path = '/admin'
    config.app_name = 'Gluttonberg 2.0'
    config.localize = true
    config.active_record.observers = ['gluttonberg/page_observer']
    
    
    
    # Load rake tasks
    rake_tasks do
      load File.join(File.dirname(__FILE__), 'rails/railties/tasks.rake')
    end
    
    # Check the gem config
    initializer "check config" do |app|

      # make sure mount_at ends with trailing slash
      config.mount_at += '/'  unless config.mount_at.last == '/'
    end

    initializer "middleware" do |app|
      app.middleware.use Gluttonberg::Middleware::Rewriter
    end
    
    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
    
  end
end
