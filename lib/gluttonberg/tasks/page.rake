namespace :gluttonberg do 
  
  # reviewed by abdul on 29/03/2011
  desc "Generate default dialect (en) and locale (au)"
  task :generate_default_dialect_and_locale => :environment do
    dialect = Gluttonberg::Dialect.create( :code => "en" , :name => "English" , :default => true)
    locale = Gluttonberg::Locale.new( :slug => "au" , :name => "Australia" , :default => true)      
    locale.dialect_ids = [dialect.id]
    locale.save!
  end
  
  desc "Generate default settings"
  task :generate_default_settings => :environment do
    Gluttonberg::Setting.generate_common_settings
  end
  
end
