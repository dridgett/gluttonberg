module Gluttonberg
  module Public
    class CommentsController <  ActionController::Base
  
      def create
        @blog = Gluttonberg::Blog.first(:conditions => {:slug => params[:blog_id]})
        @article = Gluttonberg::Article.first(:conditions => {:slug => params[:article_id], :blog_id => @blog.id})
        @comment = @article.comments.new(params[:comment])
        if @comment.save
          redirect_to blog_article_path(@blog.slug, @article.slug)
        else
          redirect_to blog_article_path(@blog.slug, @article.slug)
        end
      end
  
    end
  end
end