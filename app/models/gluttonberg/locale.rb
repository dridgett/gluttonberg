module Gluttonberg
  class Locale  < ActiveRecord::Base
    include Content::SlugManagement
    set_table_name "gb_locales"

    has_many    :page_localizations,  :class_name => "Gluttonberg::PageLocalization" , :dependent => :destroy 
    
    validates_presence_of :name , :slug
    validates_uniqueness_of :slug , :name  
    
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
    
    def self.generate_default_locale
      if Gluttonberg::Locale.find(:first , :conditions => {:slug => "en-au"}).blank?  
        locale = Gluttonberg::Locale.create( :slug => "en-au" , :name => "Australia English" , :default => true , :slug_type => Gluttonberg::Locale.prefix_slug_type )            
      end  
    end
  end
end
