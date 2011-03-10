module Gluttonberg
  class PageLocalization < ActiveRecord::Base
    belongs_to :page, :class_name => "Gluttonberg::Page"
    belongs_to :dialect
    belongs_to :locale
    set_table_name "gb_page_localizations"
    
    #acts_as_versioned
    
  end
end

