module Gluttonberg
  class Article < ActiveRecord::Base
    set_table_name "gb_articles"
    include Content::SlugManagement
    
    belongs_to :blog
    belongs_to :author, :class_name => "User"
    has_many :comments, :as => :commentable, :dependent => :destroy
    
  end
end