module Gluttonberg
  class Locale  < ActiveRecord::Base
    set_table_name "gb_locales"

    has_many    :page_localizations,  :class_name => "Gluttonberg::PageLocalization" , :dependent => :destroy 
    
    validates_presence_of :name , :slug

    SLUG_TYPES = ["prefix"]

    def  self.first_default(opts={})
      opts[:default] = true
      find(:first , :conditions => opts )
    end  
    
    def self.prefix_slug_type
      SLUG_TYPES.first
    end
    
    def self.all_slug_types
      SLUG_TYPES
    end
    
    def self.find_by_locale(locale_slug)
      find(:first , :conditions => { :slug => locale_slug } )
    end
  end
end
