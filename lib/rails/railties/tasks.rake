namespace :gluttonberg do
  
  desc "Copies migration into your rails app"
  task :copy_migrations => :environment do
    dir = File.join(File.dirname(__FILE__), '../../../db/migrate/*.rb')
    Dir[dir].each do |f|
      name = f.split('/').last
      FileUtils.cp(f, File.join(RAILS_ROOT, '/db/migrate', name))
    end
  end
end

