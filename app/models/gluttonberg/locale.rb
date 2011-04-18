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
    
    # TODO: Replace this with a scope constructed using Areal syntax
    # error fixed by abdul ON ds.id =  dls.dialect_id = ds.id
    # FIND_LOCALE_QUERY = %{
    #   SELECT 
    #     ls.*,
    #     ds.code,
    #     ds.id as dialect_id
    #   FROM gb_locales ls
    #   JOIN gb_dialects_locales dls ON dls.locale_id = ls.id
    #   JOIN gb_dialects ds ON dls.dialect_id = ds.id
    #   WHERE ls.slug = ? AND ds.code = ?
    # }.freeze

    def self.find_by_locale(locale_slug)
      #find_by_sql(sanitize_sql_array([FIND_LOCALE_QUERY, locale, dialect])).first
      find(:first , :conditions => { :slug => locale_slug } )
    end
  end
end
