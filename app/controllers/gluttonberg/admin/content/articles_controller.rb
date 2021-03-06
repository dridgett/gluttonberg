# encoding: utf-8

module Gluttonberg
  module Admin
    module Content    
      class ArticlesController < Gluttonberg::Admin::BaseController
        
        before_filter :find_blog , :except => [:create]
        before_filter :find_article, :only => [:show, :edit, :update, :delete, :destroy]
        before_filter :authorize_user , :except => [:destroy , :delete]  
        before_filter :authorize_user_for_destroy , :only => [:destroy , :delete]  
        
        def index
          conditions = {:blog_id => @blog.id}
          conditions[:user_id] = current_user.id unless current_user.super_admin?
          @articles = Article.all(:conditions => conditions).paginate(:per_page => Gluttonberg::Setting.get_setting("number_of_per_page_items"), :page => params[:page])
        end
        
        
        def show
          @comment = Comment.new
        end
        
        def new
          @article = Article.new
          @authors = User.all
        end
        
        def create
          @article = Article.new(params[:gluttonberg_article])
          if @article.save
            flash[:notice] = "The article was successfully created."
            redirect_to admin_blog_articles_path(@article.blog)
          else
            render :edit
          end
          
        end
        
        def edit
          @authors = User.all
          unless params[:version].blank?
            @version = params[:version]  
            @article.revert_to(@version)
          end
        end
        
        def update
          if @article.update_attributes(params[:gluttonberg_article])
            flash[:notice] = "The article was successfully updated."
            redirect_to admin_blog_articles_path(@blog)
          else
            flash[:error] = "Sorry, The article could not be updated."
            render :edit
          end
        end
        
        def delete
          display_delete_confirmation(
            :title      => "Delete Article '#{@article.title}'?",
            :url        => admin_blog_article_path(@blog, @article),
            :return_url => admin_blog_articles_path(@blog), 
            :warning    => ""
          )
        end
        
        def destroy
          if @article.delete
            flash[:notice] = "The article was successfully deleted."
            redirect_to admin_blog_articles_path(@blog)
          else
            flash[:error] = "There was an error deleting the Article."
            redirect_to admin_blog_articles_path(@blog)
          end
        end
        
        protected
        
          def find_blog
            @blog = Blog.find(params[:blog_id])
          end
          
          def find_article
            conditions = { :id => params[:id] }
            conditions[:user_id] = current_user.id unless current_user.super_admin?
            @article = Article.find(:first , :conditions => conditions )
          end
          
          def authorize_user
            authorize! :manage, Gluttonberg::Article
          end

          def authorize_user_for_destroy
            authorize! :destroy, Gluttonberg::Article
          end
        
      end
    end
  end
end
