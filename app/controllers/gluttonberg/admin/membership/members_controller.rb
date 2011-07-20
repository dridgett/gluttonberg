# encoding: utf-8

module Gluttonberg
  module Admin
    module Membership
      class MembersController < Gluttonberg::Admin::Membership::BaseController
        before_filter :find_member, :only => [:delete, :edit, :update, :destroy]
        before_filter :authorize_user , :except => [:edit , :update]
        
        
        def index
          @members = Member.all.paginate(:page => params[:page] , :per_page => Gluttonberg::Setting.get_setting("number_of_per_page_items") )
        end
  
        def new
          @member = Member.new
        end
  
        def create
          @password = Gluttonberg::Member.generateRandomString
          password_hash = {  
              :password => @password ,
              :password_confirmation => @password
          }
          @member = Member.new(params[:gluttonberg_member].merge(password_hash))
          @member.profile_confirmed = true
          
          if @member.save
            flash[:notice] = "Member account registered and welcome email is also sent to the member"
            MemberNotifier.welcome(@member.id).deliver            
            redirect_to :action => :index
          else
            render :action => :new
          end
        end
        
        def edit          
        end
  
        def update
          if params[:gluttonberg_member] && params[:gluttonberg_member]["image_delete"] == "1"
            params[:gluttonberg_member][:image] = nil
          end
          if @member.update_attributes(params[:gluttonberg_member])
            flash[:notice] = "Member account updated!"
            redirect_to  :action => :index
          else
            flash[:notice] = "Failed to save account changes!"
            render :action => :edit
          end 
        end
        
        def delete
          display_delete_confirmation(
            :title      => "Delete “#{@member.email}” member?",
            :url        => admin_member_path(@member),
            :return_url => admin_members_path  
          )        
        end
  
        def destroy
          if @member.destroy
            flash[:notice] = "Member deleted!"
            redirect_to :action => :index
          else
            flash[:error] = "There was an error deleting the member."
            redirect_to :action => :index
          end  
        end
  
       private
          def find_member
            @member = Member.find(params[:id])
            raise ActiveRecord::RecordNotFound  if @member.blank?
          end
          
          def authorize_user
            authorize! :manage, Member
          end
      
      end
    end
  end
end