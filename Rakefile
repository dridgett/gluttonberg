require 'rake/testtask'

Rake::TestTask.new do |test|
  test.pattern = 'test/**/*_test.rb'
  test.libs << 'test'
end


begin
  require "jeweler"
  Jeweler::Tasks.new do |gem|
    gem.name = "gluttonberg"
    gem.summary = "Gluttonberg – An Open Source Content Management System being developed by Freerange Future"
    gem.email = "office@freerangefuture.com"
    gem.authors = ["Nick Crowther","Abdul Rauf", "Luke Sutton", "Yuri Tomanek"]
    gem.files = Dir["{lib}/**/*", "{app}/**/*", "{public}/**/*", "{config}/**/*"]
  end
  Jeweler::GemcutterTasks.new
rescue
  puts "Jeweler or dependency not available."
end
