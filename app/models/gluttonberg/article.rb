module Gluttonberg
  class Article < ActiveRecord::Base
    set_table_name "gb_articles"
    include Content::SlugManagement
    include Content::Publishable
    
    belongs_to :blog
    belongs_to :author, :class_name => "User"
    has_many :comments, :as => :commentable, :dependent => :destroy
    belongs_to :featured_image , :foreign_key => :featured_image_id , :class_name => "Gluttonberg::Asset"
    
    is_versioned :non_versioned_columns => 'state'
  end
end