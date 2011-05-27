namespace :gluttonberg do 
  
  desc "Generate default locale (en-au)"
  task :generate_default_locale => :environment do
    Gluttonberg::Locale.generate_default_locale
  end
  
  desc "Generate or update default settings"
  task :generate_or_update_default_settings => :environment do
    Gluttonberg::Setting.generate_common_settings
  end
  
  desc "Copies missing assets from Railties (e.g. plugins, engines). You can specify Railties to use with FROM=railtie1,railtie2"
  task :copy_assets => :rails_env do
    begin
      Rails.application.initialize!
      app_root_path = Rails.root
      engine_root_path = Gluttonberg::Engine.root

      ["images" , "stylesheets", "javascripts"].each do |assets_dir|
        FileUtils.mkdir_p File.join(app_root_path , "public/gluttonberg/")
        FileUtils.cp_r File.join(engine_root_path , "public/gluttonberg/#{assets_dir}"), File.join(app_root_path , "public/gluttonberg/")
      end # loop
      puts "Completed"
    rescue => e
      puts "#{e}"
    end
  end #task
  
end
