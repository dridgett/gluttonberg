namespace :gluttonberg do 
  
  # reviewed by abdul on 18/04/2011
  desc "Generate default locale (en-au)"
  task :generate_default_locale => :environment do
    locale = Gluttonberg::Locale.create( :slug => "en-au" , :name => "Australia English" , :default => true , :slug_type => Gluttonberg::Locale.prefix_slug_type )      
  end
  
  desc "Generate or update default settings"
  task :generate_or_update_default_settings => :environment do
    Gluttonberg::Setting.generate_common_settings
  end
  
end
