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
  
  def create_default_public_layout
    #create pages folder
    path = File.join(Rails.root, "app", "views" , "pages" )
    FileUtils.mkdir(path) unless File.exists?(path)
    #copy layout into host app
    template "public.html.haml", File.join('app/views/layouts', "public.html.haml")    
  end
  
  def run_migration
    rake("db:migrate")
  end
  
  def bootstrap_data
    rake("gluttonberg:library:bootstrap")
    rake("gluttonberg:generate_default_locale")
    rake("gluttonberg:generate_or_update_default_settings")
  end
  
  def localization_config
    application "  # config.localize = false  "
    application "  # By Default gluttonberg applications are localized. If you do not want localized application then uncomment following line."    
    application "  "
  end
    
end

