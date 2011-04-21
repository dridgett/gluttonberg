module Gluttonberg
  module Public
    class BlogsController <  Gluttonberg::Public::BaseController
  
      def index
        if Gluttonberg::Blog.published.all.size == 0
          redirect_to "/"
        elsif Gluttonberg::Blog.published.all.size == 1
          blog = Gluttonberg::Blog.published.first
          redirect_to blog_path(blog.slug)
        else
          @blogs = Gluttonberg::Blog.published.all
        end
      end
  
      def show
        @blog = Gluttonberg::Blog.published.first(:conditions => {:slug => params[:id]}, :include => [:articles])
        raise ActiveRecord::RecordNotFound.new if @blog.blank?
        @articles = @blog.articles
      end
  
    end
  end
end