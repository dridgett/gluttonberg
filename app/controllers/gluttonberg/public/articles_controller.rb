module Gluttonberg
  module Public
    class ArticlesController <  ActionController::Base
  
      def index
        @blog = Gluttonberg::Blog.first(:conditions => {:slug => params[:blog_id]}, :include => [:articles])
        @articles = @blog.articles
      end
  
      def show
        @blog = Gluttonberg::Blog.first(:conditions => {:slug => params[:blog_id]})
        @article = Gluttonberg::Article.first(:conditions => {:slug => params[:id], :blog_id => @blog.id})
      end
  
    end
  end
end