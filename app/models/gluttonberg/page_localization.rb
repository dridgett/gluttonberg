module Gluttonberg
  class PageLocalization < ActiveRecord::Base
    belongs_to :page, :class_name => "Gluttonberg::Page"
    set_table_name "gluttonberg_page_localizations"
    
    #acts_as_versioned
    
  end
end

