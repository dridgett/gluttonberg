module Gluttonberg
  class HtmlContent < ActiveRecord::Base
    include Gluttonberg::Content::Block

    #     is_localized do
    #       property :text,           Text      
    #     end
  end
end