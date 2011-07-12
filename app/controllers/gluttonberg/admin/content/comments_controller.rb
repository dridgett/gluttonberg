# encoding: utf-8

module Gluttonberg
  module Admin
    module Content    
      class CommentsController < Gluttonberg::Admin::BaseController
        
        before_filter :find_blog
        before_filter :find_article ,  :except => [:index]
        before_filter :authorize_user ,  :except => [:moderation]
        
        def index
          find_article([:comments])
          @comments = @article.comments.paginate(:per_page => Gluttonberg::Setting.get_setting("number_of_per_page_items"), :page => params[:page])
        end
        
        def delete
          @comment = Comment.find(params[:id], :conditions => {:commentable_type => "Gluttonberg::Article", :commentable_id => @article.id})
          display_delete_confirmation(
            :title      => "Delete Comment ?",
            :url        => admin_blog_article_comment_path(@blog, @article, @comment),
            :return_url => admin_blog_article_comments_path(@blog, @article), 
            :warning    => ""
          )
        end
        
        def moderation 
          authorize_user_for_moderation
          @comment = Comment.find(params[:id], :conditions => {:commentable_type => "Gluttonberg::Article", :commentable_id => @article.id})
          @comment.moderate(params[:moderation])
          redirect_to admin_blog_article_comments_path(@blog, @article)
        end
        
        def destroy
          @comment = Comment.find(params[:id])
          if @comment.delete
            flash[:notice] = "The comment was successfully deleted."
            redirect_to admin_blog_article_comments_path(@blog, @article)
          else
            flash[:error] = "There was an error deleting the comment."
            redirect_to admin_blog_article_comments_path(@blog, @article)
          end
        end
        
        protected
        
          def find_blog
            @blog = Blog.find(params[:blog_id])
            raise ActiveRecord::RecordNotFound unless @blog
          end
          
          def find_article(include_model=[])
            conditions = { :id => params[:article_id] }
            conditions[:user_id] = current_user.id unless current_user.super_admin?
            @article = Article.find(:first , :conditions => conditions , :include => include_model )
            raise ActiveRecord::RecordNotFound unless @article
          end
        
          def authorize_user
            authorize! :manage, Gluttonberg::Comment
          end
          
          def authorize_user_for_moderation
            authorize! :moderate, Gluttonberg::Comment
          end
      end
    end
  end
end
