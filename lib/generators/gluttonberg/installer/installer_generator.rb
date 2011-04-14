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
  
  def create_page_descriptions_file
    copy_file 'page_descriptions.rb', 'config/page_descriptions.rb'
  end
  
  def run_migration
    rake("db:migrate")
  end
  
  def bootstrap_asset_library
    rake("gluttonberg:library:bootstrap")
    rake("gluttonberg:generate_default_dialect_and_locale")
    rake("gluttonberg:generate_or_update_default_settings")
  end
  
  # def require_gems
  #     gem("'acts_as_versioned', :git => 'http://github.com/technoweenie/acts_as_versioned' , :ref => 'efc726d055ac75e3684b7272561e7f9d95735738' ")
  #   end
    
end

