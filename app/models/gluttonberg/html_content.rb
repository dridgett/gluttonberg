module Gluttonberg
  class HtmlContent  < ActiveRecord::Base
    set_table_name "gb_html_contents"
    #include Gluttonberg::Content::Block

    #     is_localized do
    #       property :text,           Text      
    #     end
  end
end