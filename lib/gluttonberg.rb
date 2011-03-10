module Gluttonberg
  require 'engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require 'haml-rails'
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
  
  
  
  
  
end
