# encoding: utf-8

module Gluttonberg
  module Admin
    module Content    
      class CommentsController < Gluttonberg::Admin::BaseController
        
        before_filter :find_blog
        
        def index
          @article = Article.find(params[:article_id], :include => [:comments])
          @comments = @article.comments
        end
        
        def delete
          @article = Article.find(params[:article_id])
          @comment = Comment.find(params[:id], :conditions => {:commentable_type => "Gluttonberg::Article", :commentable_id => @article.id})
          display_delete_confirmation(
            :title      => "Delete Comment ?",
            :url        => admin_blog_article_comment_path(@blog, @article, @comment),
            :return_url => admin_blog_article_comments_path(@blog, @article), 
            :warning    => ""
          )
        end
        
        def moderation 
          @article = Article.find(params[:article_id])
          @comment = Comment.find(params[:id], :conditions => {:commentable_type => "Gluttonberg::Article", :commentable_id => @article.id})
          @comment.moderate(params[:moderation])
          redirect_to admin_blog_article_comments_path(@blog, @article)
        end
        
        def destroy
          @comment = Comment.find(params[:id])
          @article = Article.find(params[:article_id])
          if @comment.delete
            flash[:notice] = "Comment deleted."
            redirect_to admin_blog_article_comments_path(@blog, @article)
          else
            flash[:error] = "There was an error deleting the Comment."
            redirect_to admin_blog_article_comments_path(@blog, @article)
          end
        end
        
        protected
        
          def find_blog
            @blog = Blog.find(params[:blog_id])
          end
        
      end
    end
  end
end
