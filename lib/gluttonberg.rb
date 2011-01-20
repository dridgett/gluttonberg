module Gluttonberg
  require 'engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  require 'haml-rails'
  require 'gluttonberg/admin_controller_mixin'
end
