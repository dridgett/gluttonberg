module Gluttonberg
  module Admin
    module Settings

      class UsersController < Gluttonberg::Admin::ApplicationController
          
        def index
          @users = User.all
          #@users = @users.paginate(:page => params[:page] , :per_page => 20 )
        end
  
        def new
          @user = User.new
        end
  
        def create
          @user = User.new(params[:user])
          if @user.save
            # if User.count == 1
            #               @user.has_role! 'superadmin'
            #             end
            flash[:notice] = "Account registered!"
            redirect_to :action => :index
          else
            render :action => :new
          end
        end
  
  
        def edit
          #if current_user.admin?
            @user = User.find(params[:id])
          #else
          #  @user =  current_user
          #end  
        end
  
        def update
          #if current_user.admin?
            @user = User.find(params[:id])
          #else
          #  @user =  current_user
          #end
          if @user.update_attributes(params[:user])
            flash[:notice] = "Account updated!"
            redirect_to  :action => :index
          else
            render :action => :new
          end 
        end
  
        def destroy
          @user = User.find(params[:id])
          @user.destroy

          flash[:notice] = "Account deleted!"
          redirect_to :action => :index
        end
  
  
    
      
      end
    end
  end
end