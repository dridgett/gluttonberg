module Gluttonberg
  require 'engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require 'haml'
  require 'authlogic'
  require 'will_paginate'
  require 'zip/zip'
  require 'acts_as_tree'
  require 'acts_as_list'
  require 'acts_as_versioned' 
  require 'delayed_job' 
  
  require 'gluttonberg/authorizable'
  require 'gluttonberg/components'
  require 'gluttonberg/content'
  require 'gluttonberg/drag_tree' 
  require 'gluttonberg/extensions'
  require 'gluttonberg/helpers'
  require 'gluttonberg/library'
  require 'gluttonberg/page_description'
  require 'gluttonberg/templates'
  require 'gluttonberg/middleware'
  
    
    # These should likely move into one of the initializers inside of the
    # engine config. This will ensure they only run after Rails and the app
    # has been loaded.
    Helpers.setup
    DragTree.setup
    
 
  # Check to see if Gluttonberg is configured to be localized.
  def self.localized?
    Engine.config.localize
  end
  
  def self.laod_settings_from_db
    begin
      settings = Gluttonberg::Setting.find(:all , :conditions => {:enabled => true})
      settings.each do |setting|
        Engine.config.gluttonberg[setting.name.to_sym] = setting.value
      end
    rescue => e
      Rails.logger.info e
    end
  end
  require 'jeditable-rails'
end

