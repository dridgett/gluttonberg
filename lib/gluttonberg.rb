module Gluttonberg
  require 'engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require 'haml'
  require 'authlogic'
  require 'will_paginate'
  require 'zip/zip'
  require 'acts_as_tree'
  require 'acts_as_list'
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
    #Templates.setup
    Helpers.setup
    DragTree.setup
    
  
  # Checks to see if Gluttonberg has been configured to have a locale/location
  # and a translation.
  def self.localized_and_translated?
    self.localized? && self.translated?
  end
 
  # Check to see if Gluttonberg is configured to be localized.
  def self.localized?
    Engine.config.localize
  end
  
  # Check to see if Gluttonberg has been configured to translate contents.
  def self.translated?
    Engine.config.translate
  end
  
  
  
  
end

