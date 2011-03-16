module Gluttonberg
  require 'engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require 'haml'
  require 'authlogic'
  require 'will_paginate'
  require 'zip/zip'
  require 'acts_as_tree'
  require 'acts_as_list'
  require 'gluttonberg/admin_controller_mixin'
  require 'gluttonberg/public_controller_mixin'
  require 'gluttonberg/authorizable'
  require 'gluttonberg/components'
  require 'gluttonberg/content'
  require 'gluttonberg/drag_tree_helper'
  require 'gluttonberg/extensions'
  require 'gluttonberg/helpers'
  require 'gluttonberg/library'
  require 'gluttonberg/page_description'
  require 'gluttonberg/red_cloth_partials'
  require 'gluttonberg/redcloth_extensions'
  require 'gluttonberg/redcloth_helper'
  require 'gluttonberg/templates'
  require 'gluttonberg/middleware'
  
  
  
    PageDescription.setup
    #Content.setup
    #Library.setup
    #Templates.setup
    Helpers.setup
    
    
    

  
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

