module Gluttonberg
  class Dialect  < ActiveRecord::Base
    #include Gluttonberg::Authorizable
    set_table_name "gb_dialects"
    
    has_many :page_localizations, :class_name => "Gluttonberg::PageLocalization"
    has_and_belongs_to_many :locales, :class_name => "Gluttonberg::Locale"
    
    # Returns a formatted string with both the name and the ISO code for this
    # localization
    def name_and_code
      "#{name} (#{code})"
    end
    
    def  self.first_default(opts={})
      opts[:default] = true
      first(opts)
    end  
  end
end