module Gluttonberg
  class Locale  < ActiveRecord::Base
    #include Gluttonberg::Authorizable
    set_table_name "gb_locales"

    belongs_to  :fallback_locale,     :class_name => "Gluttonberg::Locale"
    has_many    :page_localizations,  :class_name => "Gluttonberg::PageLocalization" , :dependent => :destroy 
    has_and_belongs_to_many :dialects, :class_name => "Gluttonberg::Dialect" , :join_table => "gb_dialects_locales"

    attr_reader :dialect

    def  self.first_default(opts={})
      opts[:default] = true
      first(opts)
    end  
    
    # TODO: Replace this with a scope constructed using Areal syntax
    FIND_LOCALE_QUERY = %{
      SELECT 
        ls.*,
        ds.code
      FROM gb_locales ls
      JOIN gb_dialects_locales dls ON dls.locale_id = ls.id
      JOIN gb_dialects ds ON ds.id = dls.dialect_id = ds.id
      WHERE ls.slug = ? AND ds.code = ?
    }.freeze

    def self.find_by_locale(locale, dialect)
      find_by_sql(sanitize_sql_array([FIND_LOCALE_QUERY, locale, dialect])).first
    end
  end
end
