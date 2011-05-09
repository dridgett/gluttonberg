# encoding: utf-8

module Gluttonberg
  module Admin
    module Settings
      class UsersController < Gluttonberg::Admin::BaseController
        before_filter :find_user, :only => [:delete, :edit, :update, :destroy]
        before_filter :require_super_admin_user , :except => [:edit , :update]    
        def index
          unless current_user.super_admin?
            redirect_to :action => "edit" , :id => current_user.id
          end
          @users = User.all
          @users = @users.paginate(:page => params[:page] , :per_page => Rails.configuration.gluttonberg[:number_of_per_page_items] )
        end
  
        def new
          @user = User.new
        end
  
        def create
          @user = User.new(params[:user])
          if @user.save
            flash[:notice] = "Account registered!"
            redirect_to :action => :index
          else
            render :action => :new
          end
        end
  
  
        def edit          
        end
  
        def update
          if @user.update_attributes(params[:user])
            flash[:notice] = "Account updated!"
            if current_user.super_admin?
              redirect_to  :action => :index
            else
              redirect_to  :action => :edit
            end  
          else
            flash[:notice] = "Failed to save account changes!"
            render :action => :edit
          end 
        end
        
        def delete
          display_delete_confirmation(
            :title      => "Delete “#{@user.email}” user?",
            :url        => admin_user_path(@user),
            :return_url => admin_users_path  
          )        
        end
        
  
        def destroy
          if @user.destroy
            flash[:notice] = "Account deleted!"
            redirect_to :action => :index
          else
            raise ActiveResource::ServerError
          end  
        end
  
  
       private
          def find_user
            if current_user.super_admin?
             @user = User.find(params[:id])
            else
             @user =  current_user
            end
            raise ActiveRecord::RecordNotFound  unless @user
          end
    
      
      end
    end
  end
end