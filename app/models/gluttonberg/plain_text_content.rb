module Gluttonberg
  class PlainTextContent  < ActiveRecord::Base
    set_table_name "gb_plain_text_contents"
    
    include Content::Block
    
    is_localized do
          #property :text, String, :length => 255
    end
    
    # include DataMapper::Resource
    #    
    # 
    #    property :id, Serial
    #            
    #    is_localized do
    #      property :text, String, :length => 255
    #    end
  end
end