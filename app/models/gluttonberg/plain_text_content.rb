module Gluttonberg
  class PlainTextContent  < ActiveRecord::Base
    set_table_name "gb_plain_text_contents"
    
    include Content::Block
        
    
    is_localized do
    end
    
  end
end