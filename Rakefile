require 'rake/testtask'

Rake::TestTask.new do |test|
  test.pattern = 'test/**/*_test.rb'
  test.libs << 'test'
end


begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "gluttonberg"
    gem.summary = "Description of your gem"
    gem.email = "office@freerangefuture.com"
    gem.authors = ["Freerange Future - Nick Crowther, Abdul Rauf, Luke Sutton, Yuri Tomanek"]
    gem.files = Dir["{lib}/**/*", "{app}/**/*", "{public}/**/*", "{config}/**/*"]
  end
  Jeweler::GemcutterTasks.new
rescue
  puts "Jeweler or dependency not available."
end
