require 'gluttonberg'
require 'rails'

module Gluttonberg
  class Engine < Rails::Engine
    
    # Config defaults
    config.widget_factory_name = "default factory name"
    config.mount_at = '/'
    config.admin_path = '/admin'
    config.app_name = 'Gluttonberg 1.0'
    config.localize = true
    config.active_record.observers = ['gluttonberg/page_observer' , 'gluttonberg/page_localization_observer' , 'gluttonberg/locale_observer' ]
        
    config.thumbnails = {   }
    config.max_image_size = "1600x1200>"
    config.encoding = "utf-8"
    config.gluttonberg = {}
    config.identify_locale = :prefix
    
    # Load rake tasks
    rake_tasks do
      load File.join(File.dirname(__FILE__), 'rails/railties/tasks.rake')
      load File.join(File.dirname(__FILE__), 'gluttonberg/tasks/asset.rake')
      load File.join(File.dirname(__FILE__), 'gluttonberg/tasks/drag_tree.rake')
      load File.join(File.dirname(__FILE__), 'gluttonberg/tasks/page.rake')
    end
    
    # Check the gem config
    initializer "check config" do |app|

      # make sure mount_at ends with trailing slash
      config.mount_at += '/'  unless config.mount_at.last == '/'
    end

    initializer "middleware" do |app|
      app.middleware.use Gluttonberg::Middleware::Locales
      app.middleware.use Gluttonberg::Middleware::Rewriter
    end
    
    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end

    initializer "setup gluttonberg components" do |app| 
      Gluttonberg::PageDescription.setup
         
      Gluttonberg::Content.setup
      #Gluttonberg::Templates.setup
      #Gluttonberg::Helpers.setup      
      
      Gluttonberg.laod_settings_from_db
      
    end
    
    initializer "setup gluttonberg asset library" do |app| 
      Gluttonberg::Library.setup      
    end
    
  end
end
