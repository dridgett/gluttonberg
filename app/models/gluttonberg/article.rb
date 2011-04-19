module Gluttonberg
  class Article < ActiveRecord::Base
    set_table_name "gb_articles"
    
    belongs_to :blog
    include Content::SlugManagement
    belongs_to :author, :class_name => "User"
    has_many :comments, :as => :commentable, :dependent => :destroy
    
  end
end