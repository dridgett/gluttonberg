module Gluttonberg
  class HtmlContent  < ActiveRecord::Base
    include Content::Block
    set_table_name "gb_html_contents"

    is_localized do
    end
    
    #     is_localized do
    #       property :text,           Text      
    #     end
  end
end