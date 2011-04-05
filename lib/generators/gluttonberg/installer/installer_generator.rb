require 'rails/generators'
require 'rails/generators/migration'    

class Gluttonberg::InstallerGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  
  def self.source_root
    @source_root ||= File.join(File.dirname(__FILE__), 'templates')
  end
  
  def self.next_migration_number(dirname)
    if ActiveRecord::Base.timestamped_migrations
      Time.now.utc.strftime("%Y%m%d%H%M%S")
    else
      "%.3d" % (current_migration_number(dirname) + 1)
    end
  end

  def create_migration_file
    migration_template 'gluttonberg_migration.rb', 'db/migrate/gluttonberg_migration.rb'
  end
  
  # def bootstrap_asset_library
  #   Gluttonberg::Library.bootstrap
  # end
    
end

