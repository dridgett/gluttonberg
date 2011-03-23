module Gluttonberg
  class Locale  < ActiveRecord::Base
    #include Gluttonberg::Authorizable
    set_table_name "gb_locales"

    belongs_to  :fallback_locale,     :class_name => "Gluttonberg::Locale"
    has_many    :page_localizations,  :class_name => "Gluttonberg::PageLocalization"
    has_and_belongs_to_many :dialects, :class_name => "Gluttonberg::Dialect" , :join_table => "gb_dialects_locales"

    def  self.first_default(opts={})
      opts[:default] = true
      first(opts)
    end  
    
  end
end
