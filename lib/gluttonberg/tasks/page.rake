namespace :gluttonberg do 
  
  desc "Generate default locale (en-au)"
  task :generate_default_locale => :environment do
    Gluttonberg::Setting.generate_default_locale
  end
  
  desc "Generate or update default settings"
  task :generate_or_update_default_settings => :environment do
    Gluttonberg::Setting.generate_common_settings
  end
  
end
