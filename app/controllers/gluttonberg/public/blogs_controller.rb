module Gluttonberg
  module Public
    class BlogsController <  ActionController::Base
  
      def index
        if Gluttonberg::Blog.all.size == 0
          redirect_to "/"
        elsif Gluttonberg::Blog.all.size == 1
          blog = Gluttonberg::Blog.first
          redirect_to blog_path(blog.slug)
        else
          @blogs = Gluttonberg::Blog.all
        end
      end
  
      def show
        @blog = Gluttonberg::Blog.first(:conditions => {:slug => params[:id]}, :include => [:articles])
        @articles = @blog.articles
      end
  
    end
  end
end