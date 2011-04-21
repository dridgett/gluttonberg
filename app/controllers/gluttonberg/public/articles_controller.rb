module Gluttonberg
  module Public
    class ArticlesController <   Gluttonberg::Public::BaseController
      
      def index
        @blog = Gluttonberg::Blog.published.first(:conditions => {:slug => params[:blog_id]}, :include => [:articles])
        raise ActiveRecord::RecordNotFound.new if @blog.blank?
        @articles = @blog.articles
      end
  
      def show
        @blog = Gluttonberg::Blog.published.first(:conditions => {:slug => params[:blog_id]})
        raise ActiveRecord::RecordNotFound.new if @blog.blank?
        @article = Gluttonberg::Article.published.first(:conditions => {:slug => params[:id], :blog_id => @blog.id})
        raise ActiveRecord::RecordNotFound.new if @article.blank?
        @comments = @article.comments.where(:approved => true)
      end
      
  
    end
  end
end