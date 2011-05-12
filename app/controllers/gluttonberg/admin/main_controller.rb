module Gluttonberg
  module Admin
    class MainController < Gluttonberg::Admin::BaseController
      
      unloadable
      
      def index
        @categories_count = ActsAsTaggableOn::Tag.find_by_sql(%{
          select count(DISTINCT tags.id) as category_count
          from tags inner join taggings on tags.id = taggings.tag_id 
          where context = 'article_category' 
        }).first.category_count
        @tags_counts =  ActsAsTaggableOn::Tag.count - @categories_count.to_i
        
        if Comment.table_exists?
          @comments = Comment.find(:all , :order => "created_at DESC" , :limit => 10)
          @article = Article.new
          @blogs = Gluttonberg::Blog.all
          @authors = User.all
        end  
      end
      
      def show
      end
      
    end
  end
end
