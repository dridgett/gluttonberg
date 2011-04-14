# encoding: utf-8

module Gluttonberg
  module Admin
    module Settings
      class UsersController < Gluttonberg::Admin::BaseController
        before_filter :find_user, :only => [:delete, :edit, :update, :destroy]
            
        def index
          @users = User.all
          @users = @users.paginate(:page => params[:page] , :per_page => 20 )
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
            redirect_to  :action => :index
          else
            render :action => :new
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
            #if current_user.admin?
            #  @user = User.find(params[:id])
            #else
            #  @user =  current_user
            #end
            @user = User.find(params[:id])
            raise ActiveRecord::RecordNotFound  unless @user
          end
    
      
      end
    end
  end
end