# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{gluttonberg}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Your Name"]
  s.date = %q{2010-09-13}
  s.email = %q{you@email.com}
  s.extra_rdoc_files = [
    "README.rdoc"
  ]
  s.files = [
    
  ]
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Description of your gem}
  s.test_files = [
    "test/test_helper.rb",
     "test/unit/widget_test.rb"
  ]

  s.add_dependency 'haml'
  s.add_dependency "authlogic"
  s.add_dependency "will_paginate" , '~> 3.0.pre2'
  s.add_dependency "rubyzip"

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

